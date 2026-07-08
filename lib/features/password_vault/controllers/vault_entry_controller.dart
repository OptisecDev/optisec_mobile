import 'dart:math';

import 'package:get/get.dart';

import '../../../core/services/password_vault_service.dart';
import '../../../core/services/screen_security_service.dart';
import '../../../core/services/vault_clipboard_guard.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/vault_entry_model.dart';
import 'vault_controller.dart';

/// Backs both the entry detail view (view/reveal/copy/delete an existing
/// entry) and the entry edit view (create or update). Which one a given
/// route is depends only on whether `Get.arguments` supplied an existing
/// [VaultEntryModel] to edit — a `null` argument means "new entry."
///
/// The password is never part of the entry list state; it's fetched here
/// only when the detail screen reveals it or the edit screen needs to
/// prefill an existing entry's password field.
class VaultEntryController extends GetxController {
  VaultEntryModel? entry;

  final title = ''.obs;
  final username = ''.obs;
  final url = ''.obs;
  final notes = ''.obs;
  final password = ''.obs;

  final revealedPassword = Rxn<String>();
  final isRevealing = false.obs;
  final isSaving = false.obs;
  final isLoadingPassword = false.obs;
  final errorMessage = Rxn<String>();

  bool get isEditing => entry != null;

  @override
  void onInit() {
    super.onInit();
    ScreenSecurityService.instance.enable();

    final args = Get.arguments;
    if (args is VaultEntryModel) {
      entry = args;
      title.value = args.title;
      username.value = args.username;
      url.value = args.url;
      notes.value = args.notes;
      loadExistingPasswordForEditing();
    }
  }

  @override
  void onClose() {
    ScreenSecurityService.instance.disable();
    super.onClose();
  }

  /// Called by the edit view when it needs the existing password prefilled.
  Future<void> loadExistingPasswordForEditing() async {
    final id = entry?.id;
    if (id == null) return;
    isLoadingPassword.value = true;
    password.value =
        await PasswordVaultService.instance.getEntryPassword(id) ?? '';
    isLoadingPassword.value = false;
  }

  Future<void> revealPassword() async {
    final id = entry?.id;
    if (id == null || isRevealing.value) return;
    isRevealing.value = true;
    revealedPassword.value =
        await PasswordVaultService.instance.getEntryPassword(id);
    isRevealing.value = false;
  }

  void hidePassword() => revealedPassword.value = null;

  Future<void> copyToClipboard(String text) async {
    await VaultClipboardGuard.instance.copy(text);
  }

  Future<void> copyPassword() async {
    final pw = revealedPassword.value ?? await _fetchPassword();
    if (pw != null) await copyToClipboard(pw);
  }

  Future<String?> _fetchPassword() async {
    final id = entry?.id;
    if (id == null) return null;
    return PasswordVaultService.instance.getEntryPassword(id);
  }

  void generatePassword({int length = 16}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+';
    final random = Random.secure();
    password.value =
        List.generate(length, (_) => chars[random.nextInt(chars.length)])
            .join();
  }

  Future<bool> save() async {
    final l10n = AppLocalizations.of(Get.context!);
    errorMessage.value = null;
    if (title.value.trim().isEmpty) {
      errorMessage.value = l10n.vaultErrorTitleRequired;
      return false;
    }
    if (password.value.isEmpty) {
      errorMessage.value = l10n.vaultErrorPasswordRequired;
      return false;
    }

    isSaving.value = true;
    final id = await PasswordVaultService.instance.upsertEntry(
      id: entry?.id,
      title: title.value.trim(),
      username: username.value.trim(),
      url: url.value.trim(),
      notes: notes.value.trim(),
      password: password.value,
    );
    isSaving.value = false;

    if (id == null) {
      errorMessage.value = l10n.vaultErrorSaveFailed;
      return false;
    }

    if (Get.isRegistered<VaultController>()) {
      await Get.find<VaultController>().refreshEntries();
    }
    return true;
  }

  Future<bool> delete() async {
    final id = entry?.id;
    if (id == null) return false;
    if (Get.isRegistered<VaultController>()) {
      return Get.find<VaultController>().deleteEntry(id);
    }
    return PasswordVaultService.instance.deleteEntry(id);
  }
}
