class AppConstants {
  AppConstants._();

  static const String appName = 'OptiSec';
  static const String appVersion = '1.0.0';

  // Scan intervals
  static const Duration wifiScanInterval = Duration(seconds: 30);
  static const Duration privacyScanInterval = Duration(minutes: 5);

  // Score thresholds
  static const int safeScoreMin = 80;
  static const int warningScoreMin = 50;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Storage keys
  static const String keyLocale = 'app_locale';
  static const String keyOnboarded = 'app_onboarded';
  static const String keyLastScan = 'last_scan_ts';
}
