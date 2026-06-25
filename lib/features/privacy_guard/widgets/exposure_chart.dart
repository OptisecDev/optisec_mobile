import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/privacy_guard_controller.dart';

/// Horizontal per-permission exposure bars.
class ExposureChart extends StatelessWidget {
  final List<PermissionInfo> permissions;

  const ExposureChart({super.key, required this.permissions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: permissions.asMap().entries.map((e) {
        return _ExposureRow(
          perm: e.value,
          index: e.key,
          theme: theme,
        );
      }).toList(),
    );
  }
}

class _ExposureRow extends StatelessWidget {
  final PermissionInfo perm;
  final int index;
  final ThemeData theme;

  const _ExposureRow({
    required this.perm,
    required this.index,
    required this.theme,
  });

  Color get _riskColor {
    if (!perm.isGranted) return AppColors.safe;
    switch (perm.risk) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(perm.icon, size: 15, color: _riskColor),
          ),
          const SizedBox(width: 10),

          // Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(perm.nameEn,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontSize: 11)),
                    const Spacer(),
                    Text(
                      perm.isGranted
                          ? '${perm.appsCount} apps'
                          : 'Denied',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _riskColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: perm.isGranted ? perm.appsCount / 8.0 : 0,
                  ),
                  duration:
                      Duration(milliseconds: 700 + index * 100),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Stack(
                    children: [
                      // Track
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Fill
                      FractionallySizedBox(
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _riskColor.withOpacity(0.6),
                                _riskColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
