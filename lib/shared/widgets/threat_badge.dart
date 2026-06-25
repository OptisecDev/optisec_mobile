import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/wifi_network_model.dart';

class ThreatBadge extends StatelessWidget {
  final ThreatLevel level;

  const ThreatBadge({super.key, required this.level});

  Color get _bg {
    switch (level) {
      case ThreatLevel.safe:
        return AppColors.safe.withOpacity(0.15);
      case ThreatLevel.warning:
        return AppColors.warning.withOpacity(0.15);
      case ThreatLevel.danger:
        return AppColors.danger.withOpacity(0.15);
    }
  }

  Color get _fg {
    switch (level) {
      case ThreatLevel.safe:
        return AppColors.safe;
      case ThreatLevel.warning:
        return AppColors.warning;
      case ThreatLevel.danger:
        return AppColors.danger;
    }
  }

  String get _label {
    switch (level) {
      case ThreatLevel.safe:
        return 'Safe';
      case ThreatLevel.warning:
        return 'Warning';
      case ThreatLevel.danger:
        return 'Danger';
    }
  }

  IconData get _icon {
    switch (level) {
      case ThreatLevel.safe:
        return Icons.shield_rounded;
      case ThreatLevel.warning:
        return Icons.warning_amber_rounded;
      case ThreatLevel.danger:
        return Icons.dangerous_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _fg, size: 12),
          const SizedBox(width: 4),
          Text(
            _label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
