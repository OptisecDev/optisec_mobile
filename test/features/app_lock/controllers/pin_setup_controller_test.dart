import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/app_lock/controllers/pin_setup_controller.dart';
import 'package:optisec_mobile/navigation/app_routes.dart';

/// PinSetupController talks to AppLockService.instance, which is a
/// private-constructor singleton with no injection point. Same technique as
/// app_lock_service_test.dart / vault_setup_controller_test.dart: mock at
/// the MethodChannel level rather than the Dart service, which fully
/// isolates these tests from real native code while still letting us
/// assert exactly which native calls the controller triggers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const appLockChannel = MethodChannel('com.optisec.mobile/app_lock');

  final appLockCalls = <MethodCall>[];
  bool setPinShouldSucceed = true;

  setUp(() {
    appLockCalls.clear();
    setPinShouldSucceed = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLockChannel, (call) async {
      appLockCalls.add(call);
      if (call.method == 'setPin') {
        if (!setPinShouldSucceed) throw PlatformException(code: 'ERR');
        return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLockChannel, null);
    Get.reset();
  });

  Future<PinSetupController> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SizedBox()),
          GetPage(name: AppRoutes.pinSetup, page: () => const SizedBox()),
        ],
      ),
    );
    // Note: don't `await` this -- Get.toNamed's future only resolves when
    // the pushed route is later popped (mirrors Navigator.push), so
    // awaiting it here would deadlock before that ever happens.
    Get.toNamed(AppRoutes.pinSetup);
    final controller = Get.put(PinSetupController());
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> enterDigits(
    WidgetTester tester,
    PinSetupController controller,
    String digits,
  ) async {
    for (final digit in digits.split('')) {
      controller.appendDigit(digit);
    }
    await tester.pumpAndSettle();
  }

  group('entering the first PIN', () {
    testWidgets('accumulates digits up to pinLength', (tester) async {
      final controller = await pumpController(tester);

      controller.appendDigit('1');
      controller.appendDigit('2');

      expect(controller.enteredDigits, ['1', '2']);
      expect(controller.step.value, PinSetupStep.enter);
    });

    testWidgets('ignores extra digits once pinLength is reached',
        (tester) async {
      final controller = await pumpController(tester);

      await enterDigits(tester, controller, '1234');
      // Completing the first entry transitions to confirm and clears
      // enteredDigits, so this appended digit lands on the confirm step.
      controller.appendDigit('9');

      expect(controller.step.value, PinSetupStep.confirm);
      expect(controller.enteredDigits, ['9']);
    });

    testWidgets('transitions to confirm step once 4 digits are entered',
        (tester) async {
      final controller = await pumpController(tester);

      await enterDigits(tester, controller, '1234');

      expect(controller.step.value, PinSetupStep.confirm);
      expect(controller.enteredDigits, isEmpty);
      expect(appLockCalls, isEmpty);
    });

    testWidgets('backspace removes the last digit', (tester) async {
      final controller = await pumpController(tester);

      controller.appendDigit('1');
      controller.appendDigit('2');
      controller.backspace();

      expect(controller.enteredDigits, ['1']);
    });

    testWidgets('backspace on an empty entry is a no-op', (tester) async {
      final controller = await pumpController(tester);

      controller.backspace();

      expect(controller.enteredDigits, isEmpty);
    });
  });

  group('confirming the PIN', () {
    testWidgets('matching confirmation calls setPin with the entered PIN',
        (tester) async {
      final controller = await pumpController(tester);

      await enterDigits(tester, controller, '1234');
      await enterDigits(tester, controller, '1234');

      expect(appLockCalls, hasLength(1));
      expect(appLockCalls.single.method, 'setPin');
      expect(appLockCalls.single.arguments, {'pin': '1234'});
    });

    testWidgets('matching confirmation navigates back with a success result',
        (tester) async {
      final controller = await pumpController(tester);
      expect(Get.currentRoute, AppRoutes.pinSetup);

      await enterDigits(tester, controller, '1234');
      await enterDigits(tester, controller, '1234');

      expect(Get.currentRoute, '/');
      expect(controller.isSaving.value, isFalse);
    });

    testWidgets(
      'mismatched confirmation shows an error, clears digits, and does not call setPin',
      (tester) async {
        final controller = await pumpController(tester);

        await enterDigits(tester, controller, '1234');
        await enterDigits(tester, controller, '9999');

        expect(appLockCalls, isEmpty);
        expect(controller.errorMessage.value, isNotNull);
        expect(controller.enteredDigits, isEmpty);
        // Mismatch keeps the user on the confirm step to retry, rather than
        // forcing them back through the first entry.
        expect(controller.step.value, PinSetupStep.confirm);
      },
    );

    testWidgets('entering a fresh first digit after a mismatch clears the error',
        (tester) async {
      final controller = await pumpController(tester);

      await enterDigits(tester, controller, '1234');
      await enterDigits(tester, controller, '9999');
      expect(controller.errorMessage.value, isNotNull);

      controller.appendDigit('1');

      expect(controller.errorMessage.value, isNull);
    });

    testWidgets(
      'setPin failure shows an error and restarts the whole flow',
      (tester) async {
        setPinShouldSucceed = false;
        final controller = await pumpController(tester);

        await enterDigits(tester, controller, '1234');
        await enterDigits(tester, controller, '1234');

        expect(controller.errorMessage.value, isNotNull);
        expect(controller.step.value, PinSetupStep.enter);
        expect(controller.enteredDigits, isEmpty);
        expect(controller.isSaving.value, isFalse);
        // Restart must not leave the confirmed-against value around --
        // otherwise a later "1234"/"1234" attempt after a failed save
        // would silently succeed against stale state.
        expect(Get.currentRoute, AppRoutes.pinSetup);
      },
    );
  });

  group('isSaving guards input', () {
    testWidgets('appendDigit is ignored while isSaving is true',
        (tester) async {
      final controller = await pumpController(tester);
      controller.isSaving.value = true;

      controller.appendDigit('1');

      expect(controller.enteredDigits, isEmpty);
    });

    testWidgets('backspace is ignored while isSaving is true', (tester) async {
      final controller = await pumpController(tester);
      controller.appendDigit('1');
      controller.isSaving.value = true;

      controller.backspace();

      expect(controller.enteredDigits, ['1']);
    });
  });

  group('restart', () {
    testWidgets('resets step, digits, error, and the remembered first PIN',
        (tester) async {
      final controller = await pumpController(tester);
      await enterDigits(tester, controller, '1234');
      controller.appendDigit('9');

      controller.restart();

      expect(controller.step.value, PinSetupStep.enter);
      expect(controller.enteredDigits, isEmpty);
      expect(controller.errorMessage.value, isNull);

      // With _firstPin cleared, completing "enter" again and confirming
      // with the same digits must succeed rather than compare against the
      // pre-restart first PIN.
      await enterDigits(tester, controller, '5678');
      await enterDigits(tester, controller, '5678');

      expect(appLockCalls, hasLength(1));
      expect(appLockCalls.single.arguments, {'pin': '5678'});
    });
  });
}
