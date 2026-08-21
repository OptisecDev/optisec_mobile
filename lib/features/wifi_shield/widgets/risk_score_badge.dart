import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/wifi_network_model.dart';

class RiskScoreBadge extends StatelessWidget {
  final int score; // 0–100, shown as the number
  // Drives color/label instead of re-deriving thresholds from [score]: the
  // controller's evil-twin scoring is the single source of truth for a
  // network's severity, so this can never show a color that contradicts
  // ThreatBadge for the same network (previously each had its own
  // independent score thresholds, and could disagree in the 20-39 range).
  final ThreatLevel level;
  final bool compact;

  const RiskScoreBadge({
    super.key,
    required this.score,
    required this.level,
    this.compact = false,
  });

  Color get _color {
    switch (level) {
      case ThreatLevel.danger:
        return AppColors.danger;
      case ThreatLevel.warning:
        return AppColors.warning;
      case ThreatLevel.safe:
        return AppColors.safe;
    }
  }

  String _label(AppLocalizations l10n) {
    switch (level) {
      case ThreatLevel.danger:
        return score >= 70 ? l10n.wifiRiskCritical : l10n.wifiRiskHigh;
      case ThreatLevel.warning:
        return l10n.wifiRiskMedium;
      case ThreatLevel.safe:
        return l10n.wifiRiskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull(context);
  }

  Widget _buildCompact() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withValues(alpha: 0.12),
        border: Border.all(color: _color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _color,
          ),
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _label(l10n),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
