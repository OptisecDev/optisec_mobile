import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum _Strength { veryWeak, weak, fair, good, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  static _Strength _score(String password) {
    if (password.isEmpty) return _Strength.veryWeak;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      score++;
    }
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) score++;

    switch (score.clamp(0, 4)) {
      case 0:
        return _Strength.veryWeak;
      case 1:
        return _Strength.weak;
      case 2:
        return _Strength.fair;
      case 3:
        return _Strength.good;
      default:
        return _Strength.strong;
    }
  }

  static ({String label, Color color, double fraction}) describe(
    String password,
  ) {
    final strength = _score(password);
    switch (strength) {
      case _Strength.veryWeak:
        return (label: 'Very weak', color: AppColors.danger, fraction: 0.15);
      case _Strength.weak:
        return (label: 'Weak', color: AppColors.danger, fraction: 0.35);
      case _Strength.fair:
        return (label: 'Fair', color: AppColors.warning, fraction: 0.55);
      case _Strength.good:
        return (label: 'Good', color: AppColors.info, fraction: 0.75);
      case _Strength.strong:
        return (label: 'Strong', color: AppColors.safe, fraction: 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = describe(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: password.isEmpty ? 0 : result.fraction,
            minHeight: 6,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation(result.color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          password.isEmpty ? '' : result.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: result.color,
          ),
        ),
      ],
    );
  }
}
