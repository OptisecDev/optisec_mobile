import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/permission_usage_record.dart';

class PermissionTimelineTile extends StatelessWidget {
  final PermissionUsageRecord record;
  final int index;

  const PermissionTimelineTile({
    super.key,
    required this.record,
    required this.index,
  });

  IconData get _icon {
    switch (record.permissionType) {
      case 'CAMERA':
        return Icons.camera_alt_rounded;
      case 'MICROPHONE':
        return Icons.mic_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String _relativeTime(AppLocalizations l10n) {
    final time = record.lastForegroundTime;
    if (time == null) return l10n.privacyNever;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.privacyJustNow;
    if (diff.inMinutes < 60) return l10n.privacyMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.privacyHoursAgo(diff.inHours);
    return l10n.privacyDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: record.isCurrentlyInForeground
              ? AppColors.danger.withOpacity(0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 19, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.appLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (record.isCurrentlyInForeground) ...[
                      _activeDot(),
                      const SizedBox(width: 5),
                      Text(l10n.privacyOpenNow,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                      const SizedBox(width: 8),
                    ],
                    Text(_relativeTime(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textDisabled, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          _countBadge(l10n),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 55))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _activeDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
          color: AppColors.danger, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 600.ms);
  }

  Widget _countBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        l10n.privacyTimesPerWeek(record.foregroundSessionCountLast7Days),
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.info),
      ),
    );
  }
}
