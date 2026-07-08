import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/vault_setup_controller.dart';
import '../widgets/password_strength_meter.dart';

class VaultSetupView extends GetView<VaultSetupController> {
  const VaultSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.vaultSetupTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.vaultSetupSubtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => TextField(
                    obscureText: controller.obscurePassword.value,
                    onChanged: (v) => controller.masterPassword.value = v,
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
              const SizedBox(height: 8),
              Obx(() =>
                  PasswordStrengthMeter(password: controller.masterPassword.value)),
              const SizedBox(height: 16),
              Obx(() => TextField(
                    obscureText: controller.obscurePassword.value,
                    onChanged: (v) => controller.confirmPassword.value = v,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.vaultConfirmPasswordLabel,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.vaultAckText,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(() => InkWell(
                          onTap: () => controller.acknowledged.value =
                              !controller.acknowledged.value,
                          child: Row(
                            children: [
                              Checkbox(
                                value: controller.acknowledged.value,
                                onChanged: (v) =>
                                    controller.acknowledged.value = v ?? false,
                                activeColor: AppColors.primary,
                              ),
                              Expanded(
                                child: Text(
                                  l10n.vaultAckCheckbox,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 18,
                child: Obx(() => Text(
                      controller.errorMessage.value ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.danger,
                      ),
                    )),
              ),
              const SizedBox(height: 8),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.canSubmit ? controller.submit : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : Text(l10n.vaultCreateVault),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
