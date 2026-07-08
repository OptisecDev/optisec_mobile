import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/password_vault_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/subscription_model.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../controllers/vault_controller.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/vault_entry_tile.dart';

class VaultListView extends GetView<VaultController> {
  const VaultListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.passwordVault),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_outlined),
            tooltip: l10n.vaultExportVault,
            onPressed: () => _showExportDialog(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: l10n.vaultImportVault,
            onPressed: () => _showImportDialog(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: l10n.vaultAutoLockLabel,
            onPressed: () => _showAutoLockDialog(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded),
            tooltip: l10n.vaultLockVault,
            onPressed: controller.lock,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToAdd,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.vaultAddEntry),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final subscription = Get.find<SubscriptionController>();
        final showLimitBanner = !subscription.isPro &&
            controller.entries.length >= FeatureGate.freeVaultEntryLimit;

        return Column(
          children: [
            if (showLimitBanner)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Text(
                  l10n.vaultProLimitBanner,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.vaultSearchHint,
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textDisabled),
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(builder: (context) {
                final items = controller.filteredEntries;
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.vaultEmptyState,
                      style: const TextStyle(color: AppColors.textDisabled),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return VaultEntryTile(
                      entry: entry,
                      onTap: () => controller.navigateToDetail(entry),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  void _showAutoLockDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Obx(() {
        final current = controller.autoLockTimeout.value;
        Widget option(String label, Duration value) => RadioListTile<Duration>(
              value: value,
              groupValue: current,
              activeColor: AppColors.primary,
              title: Text(label,
                  style: const TextStyle(color: AppColors.textPrimary)),
              onChanged: (v) {
                if (v != null) controller.setAutoLockTimeout(v);
                Get.back();
              },
            );
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(l10n.vaultAutoLockLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(l10n.vaultAutoLockImmediate, Duration.zero),
              option(l10n.vaultAutoLockOneMinute, const Duration(minutes: 1)),
              option(l10n.vaultAutoLockFiveMinutes, const Duration(minutes: 5)),
            ],
          ),
        );
      }),
    );
  }

  void _showExportDialog(BuildContext context, AppLocalizations l10n) {
    final masterPasswordCtrl = TextEditingController();
    final exportPasswordCtrl = TextEditingController();
    final exportPassword = ''.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.vaultExportVault),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: masterPasswordCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: l10n.vaultMasterPasswordLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: exportPasswordCtrl,
              obscureText: true,
              onChanged: (v) => exportPassword.value = v,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.vaultExportPasswordLabel,
                helperText: l10n.vaultExportPasswordHint,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => PasswordStrengthMeter(password: exportPassword.value)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.vaultCancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final result = await controller.exportVault(
                masterPassword: masterPasswordCtrl.text,
                exportPassword: exportPasswordCtrl.text,
              );
              _showExportResultSnackbar(l10n, result.status);
            },
            child: Text(l10n.vaultExportButton),
          ),
        ],
      ),
    );
  }

  void _showExportResultSnackbar(AppLocalizations l10n, VaultExportStatus status) {
    final message = switch (status) {
      VaultExportStatus.success => l10n.vaultExportSuccess,
      VaultExportStatus.weakExportPassword => l10n.vaultExportWeakPassword,
      VaultExportStatus.reauthFailed => l10n.vaultExportReauthFailed,
      VaultExportStatus.cancelled => l10n.vaultExportCancelled,
      VaultExportStatus.failed => l10n.vaultExportFailed,
    };
    Get.snackbar(
      l10n.vaultExportVault,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showImportDialog(BuildContext context, AppLocalizations l10n) {
    final exportPasswordCtrl = TextEditingController();
    final merge = true.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.vaultImportVault),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exportPasswordCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: l10n.vaultExportPasswordLabel),
            ),
            const SizedBox(height: 8),
            Obx(() => RadioListTile<bool>(
                  value: true,
                  groupValue: merge.value,
                  activeColor: AppColors.primary,
                  title: Text(l10n.vaultImportMergeOption,
                      style: const TextStyle(color: AppColors.textPrimary)),
                  onChanged: (v) => merge.value = true,
                )),
            Obx(() => RadioListTile<bool>(
                  value: false,
                  groupValue: merge.value,
                  activeColor: AppColors.primary,
                  title: Text(l10n.vaultImportReplaceOption,
                      style: const TextStyle(color: AppColors.textPrimary)),
                  onChanged: (v) => merge.value = false,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.vaultCancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final result = await controller.importVault(
                exportPassword: exportPasswordCtrl.text,
                merge: merge.value,
              );
              _showImportResultSnackbar(l10n, result.status);
            },
            child: Text(l10n.vaultImportButton),
          ),
        ],
      ),
    );
  }

  void _showImportResultSnackbar(AppLocalizations l10n, VaultImportStatus status) {
    final message = switch (status) {
      VaultImportStatus.success => l10n.vaultImportSuccess,
      VaultImportStatus.badExportPassword => l10n.vaultImportBadPassword,
      VaultImportStatus.invalidFile => l10n.vaultImportInvalidFile,
      VaultImportStatus.cancelled => l10n.vaultImportCancelled,
      VaultImportStatus.notUnlocked => l10n.vaultImportNotUnlocked,
      VaultImportStatus.failed => l10n.vaultImportFailed,
    };
    Get.snackbar(
      l10n.vaultImportVault,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
