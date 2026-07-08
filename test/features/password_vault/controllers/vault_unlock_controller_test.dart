import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:optisec_mobile/features/password_vault/controllers/vault_unlock_controller.dart';
import 'package:optisec_mobile/l10n/app_localizations.dart';
import 'package:optisec_mobile/l10n/app_localizations_en.dart';
import 'package:optisec_mobile/navigation/app_routes.dart';

/// VaultUnlockController reads AppLocalizations.of(Get.context!) and talks to
/// PasswordVaultService.instance's underlying MethodChannel (no injection
/// seam on either), so these tests pump a minimal GetMaterialApp with the
/// same localization delegates main.dart registers and mock the channel --
/// same technique used throughout this test suite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const vaultChannel = MethodChannel('com.optisec.mobile/password_vault');
  const screenSecurityChannel =
      MethodChannel('com.optisec.mobile/screen_security');
  final l10n = AppLocalizationsEn();

  final vaultCalls = <MethodCall>[];

  // Mutable per-test script for how the channel should respond.
  bool canUseBiometric = false;
  bool biometricEnabled = false;
  Object? Function(MethodCall call)? unlockWithMasterPasswordHandler;
  Object? Function(MethodCall call)? unlockWithBiometricHandler;

  setUp(() {
    vaultCalls.clear();
    canUseBiometric = false;
    biometricEnabled = false;
    unlockWithMasterPasswordHandler = null;
    unlockWithBiometricHandler = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vaultChannel, (call) async {
      vaultCalls.add(call);
      switch (call.method) {
        case 'canUseBiometric':
          return canUseBiometric;
        case 'isBiometricEnabled':
          return biometricEnabled;
        case 'unlockWithMasterPassword':
          final result = unlockWithMasterPasswordHandler?.call(call);
          if (result is Exception) throw result;
          return result;
        case 'unlockWithBiometric':
          final result = unlockWithBiometricHandler?.call(call);
          if (result is Exception) throw result;
          return result;
        default:
          return null;
      }
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

  Future<VaultUnlockController> pumpController(WidgetTester tester) async {
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
    final controller = Get.put(VaultUnlockController());
    await tester.pumpAndSettle();
    return controller;
  }

  PlatformException lockedOutException(int remainingMs) =>
      PlatformException(code: 'LOCKED_OUT', details: remainingMs);

  group('isLockedOut', () {
    testWidgets('is false with no lockout set', (tester) async {
      final controller = await pumpController(tester);
      expect(controller.isLockedOut, isFalse);
    });

    testWidgets('is true when lockoutRemaining is positive', (tester) async {
      final controller = await pumpController(tester);
      controller.lockoutRemaining.value = const Duration(seconds: 5);
      expect(controller.isLockedOut, isTrue);
    });

    testWidgets('is false once lockoutRemaining reaches zero', (tester) async {
      final controller = await pumpController(tester);
      controller.lockoutRemaining.value = Duration.zero;
      expect(controller.isLockedOut, isFalse);
    });
  });

  group('submitMasterPassword lockout countdown', () {
    testWidgets(
      'a LOCKED_OUT result starts a countdown that ticks down every second and clears at zero',
      (tester) async {
        unlockWithMasterPasswordHandler = (_) => lockedOutException(3000);
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'whatever';

        await controller.submitMasterPassword();

        expect(controller.lockoutRemaining.value, const Duration(seconds: 3));
        expect(controller.isLockedOut, isTrue);
        expect(controller.errorMessage.value, l10n.vaultErrorTooManyAttempts);

        await tester.pump(const Duration(seconds: 1));
        expect(controller.lockoutRemaining.value, const Duration(seconds: 2));
        expect(controller.isLockedOut, isTrue);

        await tester.pump(const Duration(seconds: 1));
        expect(controller.lockoutRemaining.value, const Duration(seconds: 1));

        await tester.pump(const Duration(seconds: 1));
        expect(controller.lockoutRemaining.value, isNull);
        expect(controller.isLockedOut, isFalse);
        expect(controller.errorMessage.value, isNull);
      },
    );

    testWidgets(
      'submitMasterPassword is a no-op while locked out',
      (tester) async {
        unlockWithMasterPasswordHandler = (_) => lockedOutException(3000);
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'whatever';

        await controller.submitMasterPassword();
        expect(vaultCalls.where((c) => c.method == 'unlockWithMasterPassword'),
            hasLength(1));

        // Still locked out -- a second attempt must not reach the channel.
        await controller.submitMasterPassword();
        expect(vaultCalls.where((c) => c.method == 'unlockWithMasterPassword'),
            hasLength(1));
      },
    );

    testWidgets('a success result navigates to the vault', (tester) async {
      unlockWithMasterPasswordHandler = (_) => true;
      final controller = await pumpController(tester);
      controller.masterPassword.value = 'correct-password';

      await controller.submitMasterPassword();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.vault);
      expect(controller.isVerifying.value, isFalse);
    });

    testWidgets(
      'an incorrect result clears the password field and shows an error',
      (tester) async {
        unlockWithMasterPasswordHandler = (_) => false;
        final controller = await pumpController(tester);
        controller.masterPassword.value = 'wrong-password';

        await controller.submitMasterPassword();

        expect(controller.masterPassword.value, '');
        expect(
          controller.errorMessage.value,
          l10n.vaultErrorIncorrectMasterPassword,
        );
        expect(controller.isLockedOut, isFalse);
      },
    );

    testWidgets('does nothing when the password field is empty', (tester) async {
      final controller = await pumpController(tester);
      controller.masterPassword.value = '';

      await controller.submitMasterPassword();

      expect(
        vaultCalls.where((c) => c.method == 'unlockWithMasterPassword'),
        isEmpty,
      );
    });
  });

  group('tryBiometricUnlock', () {
    testWidgets('is a no-op when biometric is not enabled', (tester) async {
      biometricEnabled = false;
      final controller = await pumpController(tester);

      await controller.tryBiometricUnlock();

      expect(
        vaultCalls.where((c) => c.method == 'unlockWithBiometric'),
        isEmpty,
      );
    });

    testWidgets('a success result navigates to the vault', (tester) async {
      biometricEnabled = true;
      unlockWithBiometricHandler = (_) => true;
      final controller = await pumpController(tester);
      // _loadBiometricAvailability runs on init and sets biometricEnabled.
      await tester.pumpAndSettle();

      await controller.tryBiometricUnlock();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.vault);
    });

    testWidgets(
      'a LOCKED_OUT result starts the same countdown as master password',
      (tester) async {
        biometricEnabled = true;
        unlockWithBiometricHandler = (_) => lockedOutException(2000);
        final controller = await pumpController(tester);
        await tester.pumpAndSettle();

        await controller.tryBiometricUnlock();

        expect(controller.lockoutRemaining.value, const Duration(seconds: 2));
        expect(controller.isLockedOut, isTrue);
      },
    );

    testWidgets(
      'a keyInvalidated result disables biometric and shows an error',
      (tester) async {
        biometricEnabled = true;
        unlockWithBiometricHandler = (_) =>
            throw PlatformException(code: 'BIOMETRIC_KEY_INVALIDATED');
        final controller = await pumpController(tester);
        await tester.pumpAndSettle();

        await controller.tryBiometricUnlock();

        expect(controller.biometricEnabled.value, isFalse);
        expect(
          controller.errorMessage.value,
          l10n.vaultErrorBiometricChanged,
        );
      },
    );

    testWidgets(
      'a failed result shows an error without disabling biometric availability flag twice',
      (tester) async {
        biometricEnabled = true;
        unlockWithBiometricHandler = (_) => false;
        final controller = await pumpController(tester);
        await tester.pumpAndSettle();

        await controller.tryBiometricUnlock();

        expect(controller.errorMessage.value, l10n.vaultErrorBiometricFailed);
      },
    );
  });
}
