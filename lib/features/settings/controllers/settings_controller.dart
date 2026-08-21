import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/services/security_report_pdf_service.dart';
import '../../../features/dashboard/controllers/dashboard_controller.dart';
import '../../../features/subscription/controllers/subscription_controller.dart';
import '../../../l10n/app_localizations.dart';

class SettingsController extends GetxController {
  // ── Persistence ────────────────────────────────────────────────
  final _box = GetStorage();

  /// Public so main.dart can read the persisted language before the first
  /// frame, since this controller is lazy-loaded and may not exist yet
  /// when the app boots.
  static const languageStorageKey = 'settings_language';

  static const _kAutoScan = 'settings_auto_scan';
  static const _kScanInterval = 'settings_scan_interval_minutes';
  static const _kEvilTwinAlerts = 'settings_evil_twin_alerts';
  static const _kVpnDetection = 'settings_vpn_detection';
  static const _kPushNotifications = 'settings_push_notifications';
  static const _kThreatAlerts = 'settings_threat_alerts';
  static const _kWeeklyReport = 'settings_weekly_report';
  static const _kBiometricLock = 'settings_biometric_lock';
  static const _kAnalyticsEnabled = 'settings_analytics_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadPersisted();
    _persistOnChange();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  void _loadPersisted() {
    language.value = _box.read<String>(languageStorageKey) ?? language.value;
    autoScan.value = _box.read<bool>(_kAutoScan) ?? autoScan.value;
    scanIntervalMinutes.value =
        _box.read<int>(_kScanInterval) ?? scanIntervalMinutes.value;
    evilTwinAlerts.value =
        _box.read<bool>(_kEvilTwinAlerts) ?? evilTwinAlerts.value;
    vpnDetection.value = _box.read<bool>(_kVpnDetection) ?? vpnDetection.value;
    pushNotifications.value =
        _box.read<bool>(_kPushNotifications) ?? pushNotifications.value;
    threatAlerts.value = _box.read<bool>(_kThreatAlerts) ?? threatAlerts.value;
    weeklyReport.value = _box.read<bool>(_kWeeklyReport) ?? weeklyReport.value;
    biometricLock.value =
        _box.read<bool>(_kBiometricLock) ?? biometricLock.value;
    analyticsEnabled.value =
        _box.read<bool>(_kAnalyticsEnabled) ?? analyticsEnabled.value;

    // No Get.updateLocale() call here: main.dart already reads this same
    // persisted language and passes it as GetMaterialApp's initial locale
    // before this (lazily-loaded) controller ever exists, so by the time
    // onInit() runs, Get.locale already matches.
  }

  /// Every persisted field writes itself back to storage the moment it
  /// changes, regardless of which code path changed it (a controller
  /// method or a Switch's onChanged directly mutating `.value`).
  void _persistOnChange() {
    ever(language, (v) => _box.write(languageStorageKey, v));
    ever(autoScan, (v) => _box.write(_kAutoScan, v));
    ever(scanIntervalMinutes, (v) => _box.write(_kScanInterval, v));
    ever(evilTwinAlerts, (v) => _box.write(_kEvilTwinAlerts, v));
    ever(vpnDetection, (v) => _box.write(_kVpnDetection, v));
    ever(pushNotifications, (v) => _box.write(_kPushNotifications, v));
    ever(threatAlerts, (v) => _box.write(_kThreatAlerts, v));
    ever(weeklyReport, (v) => _box.write(_kWeeklyReport, v));
    ever(biometricLock, (v) => _box.write(_kBiometricLock, v));
    ever(analyticsEnabled, (v) => _box.write(_kAnalyticsEnabled, v));
  }

  // ── Appearance ─────────────────────────────────────────────────
  final language = 'en'.obs; // 'en' | 'ar'

  // ── Scanning ───────────────────────────────────────────────────
  final autoScan = true.obs;
  final scanIntervalMinutes = 15.obs; // options: 5, 10, 15, 30, 60
  final evilTwinAlerts = true.obs;
  final vpnDetection = true.obs;

  // ── Notifications ──────────────────────────────────────────────
  final pushNotifications = true.obs;
  final threatAlerts = true.obs;
  final weeklyReport = false.obs;
  final isExportingReport = false.obs;

  // ── Privacy & Lock ─────────────────────────────────────────────
  final biometricLock = false.obs;
  final analyticsEnabled = true.obs;

  // ── App info ───────────────────────────────────────────────────
  // Read from the actual package/build metadata (see _loadAppVersion) so
  // this can never drift out of sync with pubspec.yaml's real version, the
  // way the old hardcoded '1.0.0'/'42' silently did.
  final appVersion = ''.obs;
  final buildNumber = ''.obs;

  // ── Danger zone state ──────────────────────────────────────────
  final isResetting = false.obs;

  // ── Language ───────────────────────────────────────────────────
  void setLanguage(String lang) {
    language.value = lang;
    Get.updateLocale(Locale(lang));
  }

  String get languageLabel =>
      language.value == 'ar' ? 'العربية' : 'English';

  /// Turning the report on is a Pro perk; turning it off never needs
  /// gating since that's just opting out of something already granted.
  void setWeeklyReport(bool value) {
    if (value &&
        !Get.find<SubscriptionController>()
            .checkAccessOrPrompt(feature: 'Weekly security reports')) {
      return;
    }
    weeklyReport.value = value;
  }

  Future<void> exportSecurityReport() async {
    if (!Get.find<SubscriptionController>()
        .checkAccessOrPrompt(feature: 'PDF export')) {
      return;
    }
    if (isExportingReport.value) return;

    isExportingReport.value = true;
    try {
      await SecurityReportPdfService.generateAndShare();
    } catch (_) {
      final l10n = AppLocalizations.of(Get.context!);
      Get.snackbar(
        l10n.settingsExportReportFailedTitle,
        l10n.settingsExportReportFailedBody,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111827),
        colorText: const Color(0xFFE8F4FD),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isExportingReport.value = false;
    }
  }

  // ── Scan interval ──────────────────────────────────────────────
  static const scanIntervals = [5, 10, 15, 30, 60];

  String get scanIntervalLabel {
    final m = scanIntervalMinutes.value;
    final l10n = AppLocalizations.of(Get.context!);
    return m < 60 ? l10n.settingsEveryMinutes(m) : l10n.settingsEveryHour;
  }

  void setScanInterval(int minutes) {
    scanIntervalMinutes.value = minutes;
  }

  // ── Data management ────────────────────────────────────────────
  Future<void> clearScanHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _clearPersistedHistory();
    final l10n = AppLocalizations.of(Get.context!);
    Get.snackbar(
      l10n.settingsHistoryClearedTitle,
      l10n.settingsHistoryClearedBody,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFE8F4FD),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  /// DashboardController owns the only persisted "scan/threat history"
  /// (dashboard_daily_history) — it's registered by the same Home-shell
  /// binding as this controller, so it's always available by the time
  /// Settings can be reached.
  void _clearPersistedHistory() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().clearHistory();
    }
  }

  Future<void> resetAllData() async {
    isResetting.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    _clearPersistedHistory();

    // Reset all settings to defaults. Each assignment below persists
    // itself via the ever() listeners registered in _persistOnChange().
    language.value = 'en';
    autoScan.value = true;
    scanIntervalMinutes.value = 15;
    evilTwinAlerts.value = true;
    vpnDetection.value = true;
    pushNotifications.value = true;
    threatAlerts.value = true;
    weeklyReport.value = false;
    biometricLock.value = false;
    analyticsEnabled.value = true;
    Get.updateLocale(const Locale('en'));

    isResetting.value = false;
    final l10n = AppLocalizations.of(Get.context!);
    Get.snackbar(
      l10n.settingsDataResetTitle,
      l10n.settingsDataResetBody,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFE8F4FD),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
