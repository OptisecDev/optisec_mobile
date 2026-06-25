import 'package:get/get.dart';
import '../../../shared/models/security_score_model.dart';
import '../../../core/constants/app_constants.dart';

class DashboardController extends GetxController {
  final score = SecurityScoreModel.initial().obs;
  final isScanning = false.obs;
  final selectedChartTab = 0.obs; // 0=History, 1=Breakdown, 2=Threats

  // 7-day score history (oldest → newest)
  final scoreHistory = <double>[58, 64, 71, 55, 79, 82, 82].obs;

  // 7-day threat count per day
  final threatHistory = <double>[3.0, 1.0, 2.0, 5.0, 1.0, 2.0, 2.0].obs;

  // Security tips shown in tip carousel
  static const _tips = [
    (
      icon: 0xe8f4, // Icons.wifi_lock
      title: 'Avoid Open WiFi',
      body:
          'Never access banking or personal accounts on unsecured public WiFi. Use a VPN when you must connect.',
    ),
    (
      icon: 0xe73c, // Icons.lock
      title: 'Use WPA3 Networks',
      body:
          'WPA3 is the latest WiFi security standard. Prefer networks using WPA3 over WPA2 when available.',
    ),
    (
      icon: 0xe0da, // Icons.phone_android
      title: 'Review App Permissions',
      body:
          'Audit app permissions monthly. Remove microphone or location access from apps that don\'t need it.',
    ),
    (
      icon: 0xe897, // Icons.update
      title: 'Keep Software Updated',
      body:
          'Security patches ship in OS updates. Enable automatic updates to stay protected against known exploits.',
    ),
    (
      icon: 0xe532, // Icons.password
      title: 'Enable 2FA Everywhere',
      body:
          'Two-factor authentication blocks 99% of account takeovers even if your password is stolen.',
    ),
  ];

  int get tipCount => _tips.length;

  ({int icon, String title, String body}) tipAt(int i) => _tips[i % _tips.length];

  @override
  void onInit() {
    super.onInit();
    _loadLastScore();
  }

  void _loadLastScore() {
    score.value = SecurityScoreModel(
      overall: 82,
      wifiScore: 78,
      privacyScore: 88,
      appScore: 80,
      threatsDetected: 2,
      networksScanned: 5,
      lastScan: DateTime.now().subtract(const Duration(hours: 2)),
      scoreDelta: 3,
      threats: [
        ThreatItem(
          id: 't1',
          title: 'Open WiFi Network Detected',
          description:
              '"CoffeeShop_Free" broadcasts without encryption. Your traffic is visible to anyone on the network.',
          severity: ThreatSeverity.high,
          category: 'wifi',
          detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ThreatItem(
          id: 't2',
          title: 'Microphone Access — 4 Apps',
          description:
              'Four installed apps hold permanent microphone permission. Review and revoke unused access.',
          severity: ThreatSeverity.medium,
          category: 'privacy',
          detectedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    );
  }

  Future<void> runFullScan() async {
    if (isScanning.value) return;
    isScanning.value = true;

    await Future.delayed(const Duration(seconds: 3));

    final prev = score.value.overall;
    final newScore = score.value.copyWith(
      overall: 85,
      wifiScore: 82,
      privacyScore: 90,
      appScore: 83,
      threatsDetected: 1,
      networksScanned: 7,
      lastScan: DateTime.now(),
      scoreDelta: 85 - prev,
      threats: score.value.threats.take(1).toList(),
    );
    score.value = newScore;

    // Shift history left and append new score
    final h = List<double>.from(scoreHistory)..removeAt(0)..add(85);
    scoreHistory.value = h;

    final th = List<double>.from(threatHistory)..removeAt(0)..add(1);
    threatHistory.value = th;

    isScanning.value = false;

    Get.snackbar(
      'Scan Complete',
      'Security score updated to ${newScore.overall}/100',
      snackPosition: SnackPosition.BOTTOM,
      duration: AppConstants.animSlow * 3,
    );
  }

  void setChartTab(int tab) => selectedChartTab.value = tab;

  String get lastScanLabel {
    final diff = DateTime.now().difference(score.value.lastScan);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
