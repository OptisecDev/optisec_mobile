import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
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

  // ── Privacy & Lock ─────────────────────────────────────────────
  final biometricLock = false.obs;
  final analyticsEnabled = true.obs;

  // ── App info ───────────────────────────────────────────────────
  final appVersion = '1.0.0';
  final buildNumber = '42';

  // ── Danger zone state ──────────────────────────────────────────
  final isResetting = false.obs;

  // ── Language ───────────────────────────────────────────────────
  void setLanguage(String lang) {
    language.value = lang;
    Get.updateLocale(Locale(lang));
  }

  String get languageLabel =>
      language.value == 'ar' ? 'العربية' : 'English';

  // ── Scan interval ──────────────────────────────────────────────
  static const scanIntervals = [5, 10, 15, 30, 60];

  String get scanIntervalLabel {
    final m = scanIntervalMinutes.value;
    return m < 60 ? 'Every $m min' : 'Every hour';
  }

  void setScanInterval(int minutes) {
    scanIntervalMinutes.value = minutes;
  }

  // ── Data management ────────────────────────────────────────────
  Future<void> clearScanHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    Get.snackbar(
      'History Cleared',
      'Scan history has been erased.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFE8F4FD),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> resetAllData() async {
    isResetting.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    // Reset all settings to defaults
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
    Get.snackbar(
      'Data Reset',
      'All settings and scan data have been cleared.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFE8F4FD),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
