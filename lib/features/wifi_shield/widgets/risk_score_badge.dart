import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RiskScoreBadge extends StatelessWidget {
  final int score; // 0–100
  final bool compact;

  const RiskScoreBadge({super.key, required this.score, this.compact = false});

  Color get _color {
    if (score >= 70) return AppColors.danger;
    if (score >= 45) return const Color(0xFFFF6B35); // orange
    if (score >= 20) return AppColors.warning;
    return AppColors.safe;
  }

  String get _label {
    if (score >= 70) return 'Critical';
    if (score >= 45) return 'High';
    if (score >= 20) return 'Medium';
    return 'Low';
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
        color: _color.withOpacity(0.12),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3)),
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
            _label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
