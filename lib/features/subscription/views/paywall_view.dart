import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/subscription_model.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/plan_card.dart';

class PaywallView extends GetView<SubscriptionController> {
  const PaywallView({super.key});

  static const _benefits = [
    ('Unlimited WiFi scans', Icons.wifi_tethering_rounded),
    ('Full Evil Twin analysis', Icons.security_rounded),
    ('Weekly PDF reports', Icons.picture_as_pdf_rounded),
    ('All Cyber Academy lessons', Icons.school_rounded),
    ('Priority alerts', Icons.notifications_active_rounded),
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Unlock "$feature" with OptiSec Pro',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...List.generate(_benefits.length, (i) {
                final (label, icon) = _benefits[i];
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
                child: const Text(
                  'Restore Purchases',
                  style: TextStyle(color: AppColors.textSecondary),
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
                  badge:
                      product.id == ProductIds.proYearly ? 'BEST VALUE' : null,
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
                  : const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
