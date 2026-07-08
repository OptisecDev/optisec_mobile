import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/vault_unlock_controller.dart';

class VaultUnlockView extends GetView<VaultUnlockController> {
  const VaultUnlockView({super.key});

  String _formatRemaining(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.vaultUnlockTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: AppColors.textOnPrimary, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.vaultUnlockSubtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    enabled: !controller.isLockedOut && !controller.isVerifying.value,
                    obscureText: controller.obscurePassword.value,
                    onChanged: (v) => controller.masterPassword.value = v,
                    onSubmitted: (_) => controller.submitMasterPassword(),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.vaultMasterPasswordLabel,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textDisabled,
                        ),
                        onPressed: controller.toggleObscure,
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              Obx(() {
                final remaining = controller.lockoutRemaining.value;
                final message = controller.errorMessage.value;
                if (message == null) return const SizedBox(height: 16);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    remaining != null
                        ? '$message (${_formatRemaining(remaining)})'
                        : message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLockedOut ||
                              controller.isVerifying.value
                          ? null
                          : controller.submitMasterPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isVerifying.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : Text(l10n.vaultUnlockButton),
                    ),
                  )),
              const SizedBox(height: 12),
              Obx(() {
                if (!controller.canUseBiometric.value ||
                    !controller.biometricEnabled.value) {
                  return const SizedBox();
                }
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.isLockedOut
                        ? null
                        : controller.tryBiometricUnlock,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(l10n.vaultUseBiometric),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
