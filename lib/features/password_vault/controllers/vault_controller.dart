import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/password_vault_service.dart';
import '../../../core/services/screen_security_service.dart';
import '../../../core/services/vault_clipboard_guard.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/vault_entry_model.dart';
import '../../subscription/controllers/subscription_controller.dart';

/// Owns the unlocked vault session: the decrypted entry metadata list,
/// search, add/delete, export/import, and auto-lock.
///
/// Auto-lock uses a grace-period approach: [beginGracePeriod] /
/// [endGracePeriod] bracket any call that hands off to a system UI (the SAF
/// export/import picker, a biometric prompt) so the brief backgrounding
/// that causes doesn't get counted as "the user left the app." Only a
/// backgrounding that starts *outside* a grace period and outlasts the
/// configured timeout triggers a lock on resume.
class VaultController extends GetxController with WidgetsBindingObserver {
  final isLoading = true.obs;
  final entries = <VaultEntryModel>[].obs;
  final searchQuery = ''.obs;
  final autoLockTimeout = const Duration(minutes: 1).obs;

  DateTime? _backgroundedAt;
  bool _inGracePeriod = false;

  List<VaultEntryModel> get filteredEntries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return entries;
    return entries
        .where((e) =>
            e.title.toLowerCase().contains(query) ||
            e.username.toLowerCase().contains(query) ||
            e.url.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ScreenSecurityService.instance.enable();
    _loadAll();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    ScreenSecurityService.instance.disable();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkAutoLock();
    }
  }

  void _checkAutoLock() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null || _inGracePeriod) return;

    final timeout = autoLockTimeout.value;
    final elapsed = DateTime.now().difference(backgroundedAt);
    if (timeout == Duration.zero || elapsed >= timeout) {
      lock();
    }
  }

  void beginGracePeriod() => _inGracePeriod = true;

  void endGracePeriod() => _inGracePeriod = false;

  Future<void> _loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        PasswordVaultService.instance.listEntries(),
        PasswordVaultService.instance.getAutoLockTimeout(),
      ]);
      entries.value = results[0] as List<VaultEntryModel>;
      autoLockTimeout.value = results[1] as Duration;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEntries() async {
    entries.value = await PasswordVaultService.instance.listEntries();
  }

  Future<void> setAutoLockTimeout(Duration timeout) async {
    autoLockTimeout.value = timeout;
    await PasswordVaultService.instance.setAutoLockTimeout(timeout);
  }

  bool canAddEntry() {
    final subscriptionController = Get.find<SubscriptionController>();
    if (subscriptionController.isPro) return true;
    return entries.length < FeatureGate.freeVaultEntryLimit;
  }

  void navigateToAdd() {
    if (!canAddEntry()) {
      Get.find<SubscriptionController>()
          .checkAccessOrPrompt(feature: 'password_vault');
      return;
    }
    Get.toNamed(AppRoutes.vaultEntryEdit);
  }

  void navigateToDetail(VaultEntryModel entry) {
    Get.toNamed(AppRoutes.vaultEntryDetail, arguments: entry);
  }

  Future<bool> deleteEntry(String id) async {
    final success = await PasswordVaultService.instance.deleteEntry(id);
    if (success) {
      entries.removeWhere((e) => e.id == id);
    }
    return success;
  }

  Future<VaultExportResult> exportVault({
    required String masterPassword,
    required String exportPassword,
  }) async {
    beginGracePeriod();
    try {
      return await PasswordVaultService.instance.exportVault(
        masterPassword: masterPassword,
        exportPassword: exportPassword,
      );
    } finally {
      endGracePeriod();
    }
  }

  Future<VaultImportResult> importVault({
    required String exportPassword,
    required bool merge,
  }) async {
    beginGracePeriod();
    try {
      final result = await PasswordVaultService.instance.importVault(
        exportPassword: exportPassword,
        merge: merge,
      );
      if (result.status == VaultImportStatus.success) {
        await refreshEntries();
      }
      return result;
    } finally {
      endGracePeriod();
    }
  }

  Future<void> lock() async {
    entries.clear();
    await VaultClipboardGuard.instance.clearIfHoldingVaultContent();
    await PasswordVaultService.instance.lockVault();
    Get.offAllNamed(AppRoutes.vaultUnlock);
  }
}
