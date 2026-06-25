import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/security_score_model.dart';

class ThreatItemCard extends StatelessWidget {
  final ThreatItem threat;
  final int index;

  const ThreatItemCard({super.key, required this.threat, required this.index});

  Color get _color {
    switch (threat.severity) {
      case ThreatSeverity.critical:
        return AppColors.danger;
      case ThreatSeverity.high:
        return const Color(0xFFFF6B35);
      case ThreatSeverity.medium:
        return AppColors.warning;
      case ThreatSeverity.low:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (threat.category) {
      case 'wifi':
        return Icons.wifi_off_rounded;
      case 'privacy':
        return Icons.privacy_tip_rounded;
      case 'app':
        return Icons.bug_report_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  String get _severityLabel {
    switch (threat.severity) {
      case ThreatSeverity.critical:
        return 'CRITICAL';
      case ThreatSeverity.high:
        return 'HIGH';
      case ThreatSeverity.medium:
        return 'MEDIUM';
      case ThreatSeverity.low:
        return 'LOW';
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(threat.detectedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Severity stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_icon, color: _color, size: 15),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            threat.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _severityBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      threat.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeAgo(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, duration: 350.ms);
  }

  Widget _severityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _severityLabel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
