import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/subscription_controller.dart';

class LicenseKeyView extends GetView<SubscriptionController> {
  const LicenseKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.licenseKeyScreenTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.licenseKeyIntro,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const _LicenseKeyForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseKeyForm extends StatefulWidget {
  const _LicenseKeyForm();

  @override
  State<_LicenseKeyForm> createState() => _LicenseKeyFormState();
}

class _LicenseKeyFormState extends State<_LicenseKeyForm> {
  final _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Obx only reacts to GetX observables, not TextEditingController --
    // this listener triggers the setState that lets the Activate button's
    // enabled state track what's actually typed.
    _keyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _keyController.text = data!.text!.trim());
    }
  }

  Future<void> _activate(AppLocalizations l10n) async {
    final controller = Get.find<SubscriptionController>();
    final success = await controller.activateLicenseKey(_keyController.text);
    if (success) {
      Get.snackbar(
        l10n.licenseKeyActivatedTitle,
        l10n.licenseKeyActivatedBody,
        backgroundColor: AppColors.card,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _keyController,
          maxLines: 8,
          minLines: 3,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: l10n.licenseKeyFieldLabel,
            hintText: 'OPTM-PRO-...',
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.content_paste_rounded, color: AppColors.textDisabled),
              tooltip: l10n.licenseKeyPasteTooltip,
              onPressed: _paste,
            ),
          ),
        ),
        Obx(() {
          final error = controller.licenseKeyError.value;
          if (error == null) return const SizedBox(height: 16);
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(() => SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isActivatingLicense.value ||
                        _keyController.text.trim().isEmpty
                    ? null
                    : () => _activate(l10n),
                child: controller.isActivatingLicense.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : Text(l10n.licenseKeyActivateButton,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            )),
      ],
    );
  }
}
