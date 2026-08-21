import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/app_routes.dart';
import '../../../shared/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/plan_card.dart';

class PaywallView extends GetView<SubscriptionController> {
  const PaywallView({super.key});

  List<(String, IconData)> _benefits(AppLocalizations l10n) => [
        (l10n.wifiUnlimitedScansFeature, Icons.wifi_tethering_rounded),
        (l10n.paywallBenefitEvilTwin, Icons.security_rounded),
        (l10n.paywallBenefitPdfReports, Icons.picture_as_pdf_rounded),
        (l10n.paywallBenefitAcademyLessons, Icons.school_rounded),
        (l10n.paywallBenefitPriorityAlerts, Icons.notifications_active_rounded),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final benefits = _benefits(l10n);
    final args = Get.arguments;
    final feature = args is Map ? args['feature'] as String? : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('OptiSec Pro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (feature != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    l10n.paywallUnlockFeature(feature),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...List.generate(benefits.length, (i) {
                final (label, icon) = benefits[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Expanded(child: _PlanSelector()),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => controller.restore(),
                child: Text(
                  l10n.paywallRestorePurchases,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.licenseKeyEntry),
                child: Text(
                  l10n.paywallHaveLicenseKey,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Owns which plan is currently selected and renders both the list of
/// [PlanCard]s and the Continue button together so selection state doesn't
/// need to be threaded through the controller.
class _PlanSelector extends StatefulWidget {
  const _PlanSelector();

  @override
  State<_PlanSelector> createState() => _PlanSelectorState();
}

class _PlanSelectorState extends State<_PlanSelector> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final products = controller.products;
      _selectedId ??=
          products.firstWhereOrNull((p) => p.id == ProductIds.proYearly)?.id;
      final selected = products.firstWhereOrNull((p) => p.id == _selectedId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return PlanCard(
                  product: product,
                  badge: product.id == ProductIds.proYearly
                      ? l10n.paywallBestValueBadge
                      : null,
                  isSelected: _selectedId == product.id,
                  onTap: () => setState(() => _selectedId = product.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value || selected == null
                  ? null
                  : () => controller.purchase(selected),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : Text(
                      l10n.paywallContinueButton,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
