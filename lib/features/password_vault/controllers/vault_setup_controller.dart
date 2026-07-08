import 'package:get/get.dart';

import '../../../core/services/password_vault_service.dart';
import '../../../core/services/screen_security_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';

/// Drives first-time vault creation: choose a master password, confirm it,
/// and actively acknowledge that it can never be recovered — the vault has
/// no "forgot password" path by design, so this checkbox is a hard
/// requirement, not a formality.
class VaultSetupController extends GetxController {
  static const minPasswordLength = 8;

  final masterPassword = ''.obs;
  final confirmPassword = ''.obs;
  final acknowledged = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = Rxn<String>();
  final isSaving = false.obs;

  bool get canSubmit =>
      masterPassword.value.length >= minPasswordLength &&
      confirmPassword.value.isNotEmpty &&
      acknowledged.value &&
      !isSaving.value;

  @override
  void onInit() {
    super.onInit();
    ScreenSecurityService.instance.enable();
  }

  @override
  void onClose() {
    ScreenSecurityService.instance.disable();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.value = !obscurePassword.value;

  Future<void> submit() async {
    final l10n = AppLocalizations.of(Get.context!);
    errorMessage.value = null;

    if (masterPassword.value.length < minPasswordLength) {
      errorMessage.value = l10n.vaultErrorPasswordTooShort;
      return;
    }
    if (masterPassword.value != confirmPassword.value) {
      errorMessage.value = l10n.vaultErrorPasswordsDontMatch;
      return;
    }
    if (!acknowledged.value) {
      errorMessage.value = l10n.vaultErrorAckRequired;
      return;
    }

    isSaving.value = true;
    final success =
        await PasswordVaultService.instance.setupVault(masterPassword.value);
    isSaving.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.vault);
    } else {
      errorMessage.value = l10n.vaultErrorCreateFailed;
    }
  }
}
