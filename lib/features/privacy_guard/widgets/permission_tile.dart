import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/privacy_guard_controller.dart';
import 'permission_detail_sheet.dart';

class PermissionTile extends StatelessWidget {
  final PermissionInfo permission;
  final int index;
  final VoidCallback onRevoke;

  const PermissionTile({
    super.key,
    required this.permission,
    required this.index,
    required this.onRevoke,
  });

  Color get _riskColor {
    switch (permission.risk) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => PermissionDetailSheet.show(context, permission, onRevoke),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: permission.isGranted
                ? _riskColor.withOpacity(0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Risk stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: permission.isGranted
                      ? _riskColor
                      : AppColors.cardBorder,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    bottomLeft: Radius.circular(13),
                  ),
                ),
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                  child: Row(
                    children: [
                      // Icon container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: permission.isGranted
                              ? _riskColor.withOpacity(0.1)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          permission.icon,
                          color: permission.isGranted
                              ? _riskColor
                              : AppColors.textDisabled,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(permission.nameEn,
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(width: 6),
                                // Arabic name
                                Text(
                                  permission.nameAr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _chip(
                                  '${permission.appsCount} apps',
                                  AppColors.textDisabled,
                                ),
                                const SizedBox(width: 6),
                                _chip(
                                  permission.riskLabel,
                                  _riskColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Right: action + arrow
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (permission.isGranted)
                            GestureDetector(
                              onTap: onRevoke,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: AppColors.danger
                                          .withOpacity(0.25)),
                                ),
                                child: const Text(
                                  'Revoke',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.safe.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'Denied ✓',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.safe,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right_rounded,
                              size: 14, color: AppColors.textDisabled),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 55))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
