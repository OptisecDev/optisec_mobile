import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/privacy_guard_controller.dart';

class PermissionDetailSheet extends StatelessWidget {
  final PermissionInfo permission;
  final VoidCallback onRevoke;

  const PermissionDetailSheet({
    super.key,
    required this.permission,
    required this.onRevoke,
  });

  static void show(
      BuildContext context, PermissionInfo perm, VoidCallback onRevoke) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PermissionDetailSheet(
        permission: perm,
        onRevoke: onRevoke,
      ),
    );
  }

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
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: _riskColor.withOpacity(0.3)),
                        ),
                        child: Icon(permission.icon,
                            color: _riskColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(permission.nameEn,
                                style: theme.textTheme.titleLarge),
                            Text(
                              permission.nameAr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Cairo', fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            _RiskBadge(risk: permission.risk),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Status row
                  _StatusCard(permission: permission, riskColor: _riskColor, theme: theme),

                  const SizedBox(height: 20),

                  // Description
                  _Section(
                    theme: theme,
                    icon: Icons.info_outline_rounded,
                    title: 'What This Permission Does',
                    child: Text(
                      permission.descriptionEn,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommendation
                  _Section(
                    theme: theme,
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: AppColors.warning,
                    title: 'Recommendation',
                    child: Text(
                      permission.recommendationEn,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ),

                  // Apps with access
                  if (permission.appNames.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Section(
                      theme: theme,
                      icon: Icons.apps_rounded,
                      title:
                          'Apps with Access (${permission.appNames.length})',
                      child: Column(
                        children: permission.appNames
                            .asMap()
                            .entries
                            .map((e) => _AppRow(
                                  name: e.value,
                                  index: e.key,
                                  isGranted: permission.isGranted,
                                  theme: theme,
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Actions
                  if (permission.isGranted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onRevoke,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.block_rounded, size: 18),
                        label: const Text('Open Settings to Revoke'),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.safe.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.safe.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.safe, size: 18),
                          const SizedBox(width: 8),
                          Text('Permission Denied — You\'re Protected',
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: AppColors.safe)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String risk;

  const _RiskBadge({required this.risk});

  Color get _color {
    switch (risk) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.safe;
    }
  }

  String get _label {
    switch (risk) {
      case 'high':
        return 'High Risk';
      case 'medium':
        return 'Medium Risk';
      default:
        return 'Low Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final PermissionInfo permission;
  final Color riskColor;
  final ThemeData theme;

  const _StatusCard(
      {required this.permission,
      required this.riskColor,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statCol(
              theme,
              permission.isGranted ? 'Granted' : 'Denied',
              'Status',
              permission.isGranted ? AppColors.danger : AppColors.safe,
            ),
          ),
          Container(
              width: 1, height: 40, color: AppColors.cardBorder),
          Expanded(
            child: _statCol(theme, '${permission.appsCount}', 'Apps',
                AppColors.info),
          ),
          Container(
              width: 1, height: 40, color: AppColors.cardBorder),
          Expanded(
            child: _statCol(
                theme, permission.riskLabel, 'Risk Level', riskColor),
          ),
        ],
      ),
    );
  }

  Widget _statCol(ThemeData theme, String val, String label, Color color) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            )),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Widget child;

  const _Section({
    required this.theme,
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 15,
                color: iconColor ?? AppColors.primary),
            const SizedBox(width: 7),
            Text(title, style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _AppRow extends StatelessWidget {
  final String name;
  final int index;
  final bool isGranted;
  final ThemeData theme;

  const _AppRow({
    required this.name,
    required this.index,
    required this.isGranted,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: index < 10 ? 10 : 0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.android_rounded,
                color: AppColors.textDisabled, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: theme.textTheme.bodySmall)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.danger.withOpacity(0.1)
                  : AppColors.safe.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isGranted ? 'Granted' : 'Denied',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color:
                    isGranted ? AppColors.danger : AppColors.safe,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
