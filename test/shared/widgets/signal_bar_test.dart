import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/theme/app_colors.dart';
import 'package:optisec_mobile/shared/widgets/signal_bar.dart';

/// Regression test for the audit finding: the >=70/>=40 WiFi signal-strength
/// color thresholds were independently re-implemented in SignalBar,
/// WifiSignalBars, and network_tile.dart's _SignalProgressBar. All three now
/// defer to this single shared function.
void main() {
  group('signalColorFor', () {
    test('boundary values land in the correct color', () {
      expect(signalColorFor(100), AppColors.safe);
      expect(signalColorFor(70), AppColors.safe);
      expect(signalColorFor(69), AppColors.warning);
      expect(signalColorFor(40), AppColors.warning);
      expect(signalColorFor(39), AppColors.danger);
      expect(signalColorFor(0), AppColors.danger);
    });
  });
}
