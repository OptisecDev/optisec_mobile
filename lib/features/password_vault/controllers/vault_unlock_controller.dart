import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/password_vault_service.dart';
import '../../../core/services/screen_security_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';

/// Master-password (with optional biometric convenience) unlock screen.
/// Lockout is exponential backoff only — never a wipe — mirroring App Lock's
/// PIN lockout exactly: the same 30s-doubling-capped-at-30min policy lives
/// natively in VaultStore, this controller just reflects it as a countdown.
class VaultUnlockController extends GetxController {
  final masterPassword = ''.obs;
  final obscurePassword = true.obs;
  final errorMessage = Rxn<String>();
  final isVerifying = false.obs;
  final lockoutRemaining = Rxn<Duration>();
  final canUseBiometric = false.obs;
  final biometricEnabled = false.obs;

  Timer? _countdownTimer;

  bool get isLockedOut =>
      lockoutRemaining.value != null &&
      lockoutRemaining.value! > Duration.zero;

  @override
  void onInit() {
    super.onInit();
    ScreenSecurityService.instance.enable();
    _loadBiometricAvailability();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    ScreenSecurityService.instance.disable();
    super.onClose();
  }

  Future<void> _loadBiometricAvailability() async {
    final results = await Future.wait([
      PasswordVaultService.instance.canUseBiometric(),
      PasswordVaultService.instance.isBiometricEnabled(),
    ]);
    canUseBiometric.value = results[0];
    biometricEnabled.value = results[1];
  }

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> submitMasterPassword() async {
    if (isLockedOut || isVerifying.value || masterPassword.value.isEmpty) {
      return;
    }
    errorMessage.value = null;
    isVerifying.value = true;
    final result = await PasswordVaultService.instance
        .unlockWithMasterPassword(masterPassword.value);
    isVerifying.value = false;

    final l10n = AppLocalizations.of(Get.context!);
    switch (result.status) {
      case MasterPasswordVerifyStatus.success:
        Get.offAllNamed(AppRoutes.vault);
        break;
      case MasterPasswordVerifyStatus.incorrect:
        masterPassword.value = '';
        errorMessage.value = l10n.vaultErrorIncorrectMasterPassword;
        break;
      case MasterPasswordVerifyStatus.lockedOut:
        _startLockoutCountdown(result.lockoutRemaining ?? Duration.zero);
        break;
    }
  }

  Future<void> tryBiometricUnlock() async {
    if (isLockedOut || isVerifying.value || !biometricEnabled.value) return;
    isVerifying.value = true;
    final result = await PasswordVaultService.instance.unlockWithBiometric();
    isVerifying.value = false;

    final l10n = AppLocalizations.of(Get.context!);
    switch (result.status) {
      case BiometricUnlockStatus.success:
        Get.offAllNamed(AppRoutes.vault);
        break;
      case BiometricUnlockStatus.lockedOut:
        _startLockoutCountdown(result.lockoutRemaining ?? Duration.zero);
        break;
      case BiometricUnlockStatus.keyInvalidated:
        biometricEnabled.value = false;
        errorMessage.value = l10n.vaultErrorBiometricChanged;
        break;
      case BiometricUnlockStatus.notEnabled:
        biometricEnabled.value = false;
        break;
      case BiometricUnlockStatus.failed:
        errorMessage.value = l10n.vaultErrorBiometricFailed;
        break;
    }
  }

  void _startLockoutCountdown(Duration remaining) {
    _countdownTimer?.cancel();
    lockoutRemaining.value = remaining;
    errorMessage.value = AppLocalizations.of(Get.context!).vaultErrorTooManyAttempts;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = lockoutRemaining.value ?? Duration.zero;
      final next = current - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        lockoutRemaining.value = null;
        errorMessage.value = null;
        timer.cancel();
      } else {
        lockoutRemaining.value = next;
      }
    });
  }
}
