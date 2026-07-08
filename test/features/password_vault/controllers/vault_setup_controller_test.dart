import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/password_vault/controllers/vault_setup_controller.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:optisec_mobile/l10n/app_localizations_en.dart';
import 'package:optisec_mobile/navigation/app_routes.dart';

/// VaultSetupController.submit() reads AppLocalizations.of(Get.context!), so
/// these tests pump a minimal GetMaterialApp with the same localization
/// delegates/routes main.dart registers, then read PasswordVaultService's
/// underlying MethodChannel (no injection seam exists) the same way
/// password_vault_service_test.dart and vault_controller_test.dart do.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const vaultChannel = MethodChannel('com.optisec.mobile/password_vault');
  const screenSecurityChannel =
      MethodChannel('com.optisec.mobile/screen_security');
  final l10n = AppLocalizationsEn();

  final vaultCalls = <MethodCall>[];
  bool setupShouldSucceed = true;

  setUp(() {
    vaultCalls.clear();
    setupShouldSucceed = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vaultChannel, (call) async {
      vaultCalls.add(call);
      if (call.method == 'setupVault') {
        if (!setupShouldSucceed) throw PlatformException(code: 'ERR');
        return null;
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      screenSecurityChannel,
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vaultChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(screenSecurityChannel, null);
    Get.reset();
  });

  Future<VaultSetupController> pumpController(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        getPages: [
          GetPage(name: '/', page: () => const SizedBox()),
          GetPage(name: AppRoutes.vault, page: () => const SizedBox()),
        ],
      ),
    );
    final controller = Get.put(VaultSetupController());
    await tester.pumpAndSettle();
    return controller;
  }

  group('canSubmit', () {
    testWidgets('is false when acknowledgment is not checked', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'longenough';
      controller.confirmPassword.value = 'longenough';
      controller.acknowledged.value = false;

      expect(controller.canSubmit, isFalse);
    });

    testWidgets('is false when the password is too short', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'short';
      controller.confirmPassword.value = 'short';
      controller.acknowledged.value = true;

      expect(controller.canSubmit, isFalse);
    });

    testWidgets('is false when confirmPassword is empty', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'longenough';
      controller.confirmPassword.value = '';
      controller.acknowledged.value = true;

      expect(controller.canSubmit, isFalse);
    });

    testWidgets('is false while a submission is already saving', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'longenough';
      controller.confirmPassword.value = 'longenough';
      controller.acknowledged.value = true;
      controller.isSaving.value = true;

      expect(controller.canSubmit, isFalse);
    });

    testWidgets(
      'is true once length, confirmation, and acknowledgment are all satisfied',
      (tester) async {
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'longenough';
        controller.confirmPassword.value = 'longenough';
        controller.acknowledged.value = true;

        expect(controller.canSubmit, isTrue);
      },
    );
  });

  group('submit requires acknowledgment', () {
    testWidgets(
      'does not call setupVault and shows the ack-required error when unchecked',
      (tester) async {
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'longenough';
        controller.confirmPassword.value = 'longenough';
        controller.acknowledged.value = false;

        await controller.submit();

        expect(vaultCalls, isEmpty);
        expect(controller.errorMessage.value, l10n.vaultErrorAckRequired);
      },
    );

    testWidgets(
      'calls setupVault once acknowledgment is checked alongside valid passwords',
      (tester) async {
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'longenough';
        controller.confirmPassword.value = 'longenough';
        controller.acknowledged.value = true;

        await controller.submit();

        expect(vaultCalls, hasLength(1));
        expect(vaultCalls.single.method, 'setupVault');
        expect(
          vaultCalls.single.arguments,
          {'masterPassword': 'longenough'},
        );
      },
    );
  });

  group('submit validation ordering', () {
    testWidgets(
      'rejects a too-short password before ever checking acknowledgment',
      (tester) async {
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'short';
        controller.confirmPassword.value = 'short';
        controller.acknowledged.value = false;

        await controller.submit();

        expect(vaultCalls, isEmpty);
        expect(controller.errorMessage.value, l10n.vaultErrorPasswordTooShort);
      },
    );

    testWidgets(
      'rejects mismatched passwords before checking acknowledgment',
      (tester) async {
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'longenough';
        controller.confirmPassword.value = 'somethingelse';
        controller.acknowledged.value = false;

        await controller.submit();

        expect(vaultCalls, isEmpty);
        expect(
          controller.errorMessage.value,
          l10n.vaultErrorPasswordsDontMatch,
        );
      },
    );
  });

  group('submit outcomes', () {
    testWidgets('navigates to the vault on success', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'longenough';
      controller.confirmPassword.value = 'longenough';
      controller.acknowledged.value = true;

      await controller.submit();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.vault);
      expect(controller.isSaving.value, isFalse);
    });

    testWidgets(
      'shows the create-failed error and does not navigate when the service reports failure',
      (tester) async {
        setupShouldSucceed = false;
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'longenough';
        controller.confirmPassword.value = 'longenough';
        controller.acknowledged.value = true;

        await controller.submit();
        await tester.pumpAndSettle();

        expect(controller.errorMessage.value, l10n.vaultErrorCreateFailed);
        expect(Get.currentRoute, isNot(AppRoutes.vault));
        expect(controller.isSaving.value, isFalse);
      },
    );
  });
}
