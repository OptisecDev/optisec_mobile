import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SignalBar extends StatelessWidget {
  final int percent; // 0-100
  final double height;

  const SignalBar({super.key, required this.percent, this.height = 6});

  Color get _color {
    if (percent >= 70) return AppColors.safe;
    if (percent >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: percent / 100,
        minHeight: height,
        backgroundColor: AppColors.cardBorder,
        valueColor: AlwaysStoppedAnimation<Color>(_color),
      ),
    );
  }
}
