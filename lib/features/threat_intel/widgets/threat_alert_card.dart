import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/threat_alert_model.dart';

class ThreatAlertCard extends StatefulWidget {
  final ThreatAlert alert;
  final int index;

  const ThreatAlertCard({
    super.key,
    required this.alert,
    required this.index,
  });

  @override
  State<ThreatAlertCard> createState() => _ThreatAlertCardState();
}

class _ThreatAlertCardState extends State<ThreatAlertCard> {
  bool _expanded = false;

  Color get _color {
    switch (widget.alert.severity) {
      case AlertSeverity.critical:
        return AppColors.danger;
      case AlertSeverity.high:
        return const Color(0xFFFF6B35);
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.low:
        return AppColors.info;
    }
  }

  String get _severityLabel {
    switch (widget.alert.severity) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.high:
        return 'HIGH';
      case AlertSeverity.medium:
        return 'MEDIUM';
      case AlertSeverity.low:
        return 'LOW';
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(widget.alert.publishedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alert = widget.alert;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public_rounded, color: _color, size: 15),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        alert.title,
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
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textDisabled),
                    const SizedBox(width: 3),
                    Text(
                      alert.region,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _timeAgo(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 16,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.5,
                            height: 1.5,
                          ),
                        ),
                        if (alert.mitreTechnique != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'MITRE ${alert.mitreTechnique}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 70))
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
