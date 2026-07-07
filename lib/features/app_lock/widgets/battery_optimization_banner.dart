import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Warns that OS battery optimization can kill the foreground monitor
/// service, silently disabling App Lock. Shown only while at least one app
/// is locked and the app isn't yet exempted.
class BatteryOptimizationBanner extends StatelessWidget {
  final VoidCallback onFix;

  const BatteryOptimizationBanner({super.key, required this.onFix});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.battery_alert_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Battery optimization may stop App Lock',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Allow unrestricted background activity so locked apps stay protected.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: onFix,
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Fix'),
          ),
        ],
      ),
    );
  }
}
