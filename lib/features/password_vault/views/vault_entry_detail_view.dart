import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../controllers/vault_entry_controller.dart';

class VaultEntryDetailView extends GetView<VaultEntryController> {
  const VaultEntryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.vaultEntryDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                Get.toNamed(AppRoutes.vaultEntryEdit, arguments: controller.entry),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              controller.title.value.isEmpty ? 'Untitled' : controller.title.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            if (controller.username.value.isNotEmpty)
              _FieldRow(
                label: l10n.vaultFieldUsername,
                value: controller.username.value,
                onCopy: () => controller.copyToClipboard(controller.username.value),
              ),
            _PasswordRow(controller: controller, l10n: l10n),
            if (controller.url.value.isNotEmpty)
              _FieldRow(
                label: l10n.vaultFieldUrl,
                value: controller.url.value,
                onCopy: () => controller.copyToClipboard(controller.url.value),
              ),
            if (controller.notes.value.isNotEmpty)
              _FieldRow(label: l10n.vaultFieldNotes, value: controller.notes.value),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.vaultDeleteConfirmTitle),
        content: Text(l10n.vaultDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.vaultCancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.delete();
              if (success) Get.back();
            },
            child: Text(l10n.vaultDelete,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _FieldRow({required this.label, required this.value, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textDisabled)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded,
                  size: 18, color: AppColors.textDisabled),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  final VaultEntryController controller;
  final AppLocalizations l10n;

  const _PasswordRow({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.vaultFieldPassword,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textDisabled)),
                const SizedBox(height: 4),
                Obx(() {
                  final revealed = controller.revealedPassword.value;
                  if (controller.isRevealing.value) {
                    return const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return Text(
                    revealed ?? '••••••••••',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() => IconButton(
                icon: Icon(
                  controller.revealedPassword.value != null
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
                onPressed: controller.revealedPassword.value != null
                    ? controller.hidePassword
                    : controller.revealPassword,
              )),
          IconButton(
            icon: const Icon(Icons.copy_rounded,
                size: 18, color: AppColors.textDisabled),
            onPressed: () async {
              await controller.copyPassword();
              Get.snackbar(
                l10n.vaultCopy,
                l10n.vaultCopied,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
    );
  }
}
