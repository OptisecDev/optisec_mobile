import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum _Strength { veryWeak, weak, fair, good, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  /// When true, scores against the export file's actual native requirement
  /// (>=10 chars and >=3 of the 4 character classes — see
  /// VaultExportImportManager.isExportPasswordStrongEnough) instead of the
  /// generic heuristic, so "Strong" never shows for a password the native
  /// side will reject with WEAK_EXPORT_PASSWORD.
  final bool strict;

  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.strict = false,
  });

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

  static _Strength _scoreExport(String password) {
    if (password.isEmpty) return _Strength.veryWeak;

    var classes = 0;
    if (password.contains(RegExp(r'[a-z]'))) classes++;
    if (password.contains(RegExp(r'[A-Z]'))) classes++;
    if (password.contains(RegExp(r'[0-9]'))) classes++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) classes++;

    // Mirrors VaultExportImportManager.isExportPasswordStrongEnough exactly:
    // only a password that will actually pass native validation may be
    // reported as "Strong".
    if (password.length >= 10 && classes >= 3) return _Strength.strong;

    var score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    score += (classes - 1).clamp(0, 2);

    switch (score.clamp(0, 3)) {
      case 0:
        return _Strength.veryWeak;
      case 1:
        return _Strength.weak;
      case 2:
        return _Strength.fair;
      default:
        return _Strength.good;
    }
  }

  static ({String label, Color color, double fraction}) describe(
    String password, {
    bool strict = false,
  }) {
    final strength = strict ? _scoreExport(password) : _score(password);
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
    final result = describe(password, strict: strict);
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
