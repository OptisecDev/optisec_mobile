import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/threat_intel_controller.dart';
import '../widgets/threat_alert_card.dart';

class ThreatIntelView extends GetView<ThreatIntelController> {
  const ThreatIntelView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.threatIntelTitle),
        actions: [
          Obx(() => IconButton(
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.refresh(forceRefresh: true),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(forceRefresh: true),
        child: Obx(() {
          final alerts = controller.alerts;

          if (controller.isLoading.value && alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (alerts.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    l10n.threatIntelEmpty,
                    style: const TextStyle(color: AppColors.textDisabled),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: alerts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Obx(() => Text(
                        controller.lastUpdated.value != null
                            ? l10n.threatIntelFeedUpdated(
                                _timeAgo(l10n, controller.lastUpdated.value!))
                            : l10n.threatIntelFeedNotLoaded,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      )),
                );
              }
              final alert = alerts[index - 1];
              return ThreatAlertCard(alert: alert, index: index - 1);
            },
          );
        }),
      ),
    );
  }

  String _timeAgo(AppLocalizations l10n, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.threatIntelJustNow;
    if (diff.inHours < 1) return l10n.threatIntelMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.threatIntelHoursAgo(diff.inHours);
    return l10n.threatIntelDaysAgo(diff.inDays);
  }
}
