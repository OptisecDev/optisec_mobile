import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../controllers/vault_entry_controller.dart';
import '../widgets/password_strength_meter.dart';

class VaultEntryEditView extends GetView<VaultEntryController> {
  const VaultEntryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          controller.isEditing
              ? l10n.vaultEntryEditTitleEdit
              : l10n.vaultEntryEditTitleNew,
        ),
      ),
      body: SafeArea(
        child: _EditForm(controller: controller, l10n: l10n),
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  final VaultEntryController controller;
  final AppLocalizations l10n;

  const _EditForm({required this.controller, required this.l10n});

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _passwordCtrl;
  Worker? _passwordWorker;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _titleCtrl = TextEditingController(text: c.title.value);
    _usernameCtrl = TextEditingController(text: c.username.value);
    _urlCtrl = TextEditingController(text: c.url.value);
    _notesCtrl = TextEditingController(text: c.notes.value);
    _passwordCtrl = TextEditingController(text: c.password.value);

    // Keeps the field in sync when the controller's password changes
    // externally (async prefill for an existing entry, or "Generate"),
    // without disturbing the cursor while the user is typing.
    _passwordWorker = ever<String>(c.password, (value) {
      if (_passwordCtrl.text != value) _passwordCtrl.text = value;
    });
  }

  @override
  void dispose() {
    _passwordWorker?.dispose();
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = widget.l10n;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _field(
          controller: _titleCtrl,
          label: l10n.vaultFieldTitle,
          onChanged: (v) => controller.title.value = v,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _usernameCtrl,
          label: l10n.vaultFieldUsername,
          onChanged: (v) => controller.username.value = v,
        ),
        const SizedBox(height: 14),
        Obx(() => TextField(
              controller: _passwordCtrl,
              obscureText: false,
              onChanged: (v) => controller.password.value = v,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.vaultFieldPassword,
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: controller.isLoadingPassword.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.casino_outlined,
                          color: AppColors.textDisabled),
                  tooltip: l10n.vaultGeneratePassword,
                  onPressed: controller.generatePassword,
                ),
              ),
            )),
        const SizedBox(height: 8),
        Obx(() =>
            PasswordStrengthMeter(password: controller.password.value)),
        const SizedBox(height: 14),
        _field(
          controller: _urlCtrl,
          label: l10n.vaultFieldUrl,
          onChanged: (v) => controller.url.value = v,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _notesCtrl,
          label: l10n.vaultFieldNotes,
          maxLines: 3,
          onChanged: (v) => controller.notes.value = v,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 18,
          child: Obx(() => Text(
                controller.errorMessage.value ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              )),
        ),
        const SizedBox(height: 8),
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSaving.value
                    ? null
                    : () async {
                        final success = await controller.save();
                        if (success) {
                          Get.until((route) =>
                              route.settings.name == AppRoutes.vault);
                        }
                      },
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
                    : Text(l10n.vaultSave),
              ),
            )),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
