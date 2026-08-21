import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Single source of truth for the >=70/>=40 WiFi signal-strength color
/// thresholds -- was independently re-implemented in SignalBar, WifiSignalBars
/// (features/wifi_shield/widgets/wifi_signal_bars.dart), and network_tile.dart's
/// _SignalProgressBar. Any future change to the thresholds now needs one edit
/// instead of three.
Color signalColorFor(int percent) {
  if (percent >= 70) return AppColors.safe;
  if (percent >= 40) return AppColors.warning;
  return AppColors.danger;
}

class SignalBar extends StatelessWidget {
  final int percent; // 0-100
  final double height;

  const SignalBar({super.key, required this.percent, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: percent / 100,
        minHeight: height,
        backgroundColor: AppColors.cardBorder,
        valueColor: AlwaysStoppedAnimation<Color>(signalColorFor(percent)),
      ),
    );
  }
}
