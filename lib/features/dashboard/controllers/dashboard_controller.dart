import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../shared/models/security_score_model.dart';
import '../../../shared/models/wifi_network_model.dart';
import '../../privacy_guard/controllers/privacy_guard_controller.dart';
import '../../wifi_shield/controllers/wifi_shield_controller.dart';

class DashboardController extends GetxController {
  final score = SecurityScoreModel.initial().obs;
  final isScanning = false.obs;
  final selectedChartTab = 0.obs; // 0=History, 1=Breakdown, 2=Threats

  // 7-day score/threat history, oldest -> newest, built from persisted
  // real daily snapshots (see _buildScoreHistory/_buildThreatHistory).
  // Days before the app has any recorded data flat-fill from the nearest
  // known real value rather than inventing a trend.
  final scoreHistory = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  final threatHistory = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  final _box = GetStorage();

  static const _historyStorageKey = 'dashboard_daily_history';
  static const _historyRetentionDays = 14;

  // _recomputeScore() is fire-and-forget from onInit()'s everAll() listener
  // and can overlap with runFullScan()'s own awaited call to it -- an older
  // invocation finishing after a newer one would otherwise overwrite a
  // fresher score with a stale one. Each call captures the token current at
  // its start and only writes if it's still the latest by the time its
  // awaits resolve, so a stale result is silently discarded instead of
  // racing into `score.value`.
  int _recomputeToken = 0;

  // Security tips shown in tip carousel
  static const _tips = [
    (
      icon: IconData(0xe8f4, fontFamily: 'MaterialIcons'), // Icons.wifi_lock
      title: 'Avoid Open WiFi',
      body:
          'Never access banking or personal accounts on unsecured public WiFi. Use a VPN when you must connect.',
    ),
    (
      icon: IconData(0xe73c, fontFamily: 'MaterialIcons'), // Icons.lock
      title: 'Use WPA3 Networks',
      body:
          'WPA3 is the latest WiFi security standard. Prefer networks using WPA3 over WPA2 when available.',
    ),
    (
      icon: IconData(0xe0da, fontFamily: 'MaterialIcons'), // Icons.phone_android
      title: 'Review App Permissions',
      body:
          'Audit app permissions monthly. Remove microphone or location access from apps that don\'t need it.',
    ),
    (
      icon: IconData(0xe897, fontFamily: 'MaterialIcons'), // Icons.update
      title: 'Keep Software Updated',
      body:
          'Security patches ship in OS updates. Enable automatic updates to stay protected against known exploits.',
    ),
    (
      icon: IconData(0xe532, fontFamily: 'MaterialIcons'), // Icons.password
      title: 'Enable 2FA Everywhere',
      body:
          'Two-factor authentication blocks 99% of account takeovers even if your password is stolen.',
    ),
  ];

  int get tipCount => _tips.length;

  ({IconData icon, String title, String body}) tipAt(int i) =>
      _tips[i % _tips.length];

  @override
  void onInit() {
    super.onInit();

    final wifi = Get.find<WifiShieldController>();
    final privacy = Get.find<PrivacyGuardController>();

    // WifiShieldController and PrivacyGuardController run their own scans
    // asynchronously as soon as they're constructed (same shell binding as
    // this controller) -- recompute whenever either produces new real data,
    // instead of only on the initial, possibly-still-empty snapshot.
    everAll(<RxInterface>[wifi.networks, privacy.privacyScore],
        (_) => _recomputeScore());

    _recomputeScore();
  }

  /// Pulls current state from WifiShieldController, PrivacyGuardController,
  /// and AppLockService and derives the dashboard's score/threats from it.
  /// Never fabricates a number -- a module with nothing scanned yet just
  /// contributes its optimistic default (see each `_xScore` helper).
  Future<void> _recomputeScore() async {
    final token = ++_recomputeToken;

    final wifi = Get.find<WifiShieldController>();
    final privacy = Get.find<PrivacyGuardController>();

    final wifiScore = (100 - wifi.overallRisk).clamp(0, 100);
    final privacyScoreValue = privacy.privacyScore.value;
    final isPinSet = await AppLockService.instance.isPinSet();
    final appScore = await _computeAppScore(isPinSet);

    // A newer recompute started (and will write a fresher result) while
    // this one was awaiting -- don't let this stale one overwrite it.
    if (token != _recomputeToken) return;

    final overall =
        ((wifiScore + privacyScoreValue + appScore) / 3).round().clamp(0, 100);

    final threats = <ThreatItem>[
      ..._wifiThreats(wifi),
      ..._privacyThreats(privacy),
      ..._appLockThreats(isPinSet),
    ];

    final networksScanned = wifi.safeCount + wifi.threatCount;

    final history = _readHistory();
    final previousDayOverall = _previousDayOverall(history);

    score.value = SecurityScoreModel(
      overall: overall,
      wifiScore: wifiScore,
      privacyScore: privacyScoreValue,
      appScore: appScore,
      threatsDetected: threats.length,
      networksScanned: networksScanned,
      lastScan: DateTime.now(),
      scoreDelta: previousDayOverall == null ? 0 : overall - previousDayOverall,
      threats: threats,
    );

    _recordToday(history, overall, threats.length);
    scoreHistory.value = _buildScoreHistory(history, overall);
    threatHistory.value = _buildThreatHistory(history, threats.length);
  }

  Future<int> _computeAppScore(bool isPinSet) async {
    final lockedApps = await AppLockService.instance.getLockedApps();
    final monitorRunning = await AppLockService.instance.isMonitorServiceRunning();

    // Baseline reflects "no App Lock protection configured"; each real,
    // independently-verifiable signal below raises it.
    var appScore = 40;
    if (isPinSet) appScore += 30;
    if (lockedApps.isNotEmpty) appScore += 20;
    if (monitorRunning) appScore += 10;
    return appScore.clamp(0, 100);
  }

  List<ThreatItem> _wifiThreats(WifiShieldController wifi) {
    final items = <ThreatItem>[];

    // Group by SSID: several flagged BSSIDs for the same network (e.g. a
    // dual-band router or mesh system with more than one access point) are
    // one threat to the user, not one card per access point.
    final bySsid = <String, List<WifiNetworkModel>>{};
    for (final n in wifi.evilTwins) {
      bySsid.putIfAbsent(n.ssid.toLowerCase(), () => []).add(n);
    }
    for (final group in bySsid.values) {
      final ssid = group.first.ssid;
      final reasons = group.expand((n) => n.threats).toSet().join(' ');
      final maxRisk =
          group.map((n) => n.riskScore).reduce((a, b) => a > b ? a : b);
      final baseDescription = reasons.isNotEmpty
          ? reasons
          : 'This network shows signs of impersonating a network you trust.';
      items.add(ThreatItem(
        id: 'wifi_evil_twin_${ssid.toLowerCase()}',
        title: 'Evil Twin Suspected: $ssid',
        description: group.length > 1
            ? '$baseDescription (${group.length} access points affected)'
            : baseDescription,
        severity:
            maxRisk >= 70 ? ThreatSeverity.critical : ThreatSeverity.high,
        category: 'wifi',
        detectedAt: DateTime.now(),
      ));
    }

    final connected = wifi.connectedNetwork;
    if (connected != null &&
        connected.security == WifiSecurity.open &&
        !connected.isEvilTwin) {
      items.add(ThreatItem(
        id: 'wifi_connected_open',
        title: 'Connected to an Open Network',
        description:
            '"${connected.ssid}" has no encryption. Traffic on this network can be read by others nearby.',
        severity: ThreatSeverity.high,
        category: 'wifi',
        detectedAt: DateTime.now(),
      ));
    }
    return items;
  }

  List<ThreatItem> _privacyThreats(PrivacyGuardController privacy) {
    return privacy.permissions
        .where((p) => p.isGranted && (p.risk == 'high' || p.risk == 'medium'))
        .map((p) => ThreatItem(
              id: 'privacy_${p.id}',
              title: '${p.nameEn} Access Granted',
              description: p.descriptionEn,
              severity: p.risk == 'high'
                  ? ThreatSeverity.high
                  : ThreatSeverity.medium,
              category: 'privacy',
              detectedAt: DateTime.now(),
            ))
        .toList();
  }

  List<ThreatItem> _appLockThreats(bool isPinSet) {
    if (isPinSet) return const [];
    return [
      ThreatItem(
        id: 'app_lock_not_configured',
        title: 'App Lock Is Not Set Up',
        description:
            'No PIN has been set, so sensitive apps are not protected behind a lock screen.',
        severity: ThreatSeverity.medium,
        category: 'app',
        detectedAt: DateTime.now(),
      ),
    ];
  }

  /// Wipes the persisted daily score/threat history and resets the visible
  /// chart back to empty. Used by Settings' "Clear Scan History" and
  /// "Reset All Data" actions.
  void clearHistory() {
    _box.remove(_historyStorageKey);
    scoreHistory.value = List<double>.filled(7, 0);
    threatHistory.value = List<double>.filled(7, 0);
  }

  // ── Persisted daily history ──────────────────────────────────────
  // Keyed by 'YYYY-MM-DD' -> {overall, threats}, so the 7-day charts
  // survive app restarts and reflect real computed scores, not a
  // synthetic trend.

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> _readHistory() {
    final raw = _box.read<Map>(_historyStorageKey);
    return raw == null ? {} : Map<String, dynamic>.from(raw);
  }

  int? _previousDayOverall(Map<String, dynamic> history) {
    final todayKey = _dateKey(DateTime.now());
    final priorKeys = history.keys.where((k) => k != todayKey).toList()
      ..sort();
    if (priorKeys.isEmpty) return null;
    final entry = history[priorKeys.last];
    if (entry is Map && entry['overall'] is num) {
      return (entry['overall'] as num).toInt();
    }
    return null;
  }

  void _recordToday(Map<String, dynamic> history, int overall, int threats) {
    final todayKey = _dateKey(DateTime.now());
    history[todayKey] = {'overall': overall, 'threats': threats};

    final cutoff =
        DateTime.now().subtract(const Duration(days: _historyRetentionDays));
    history.removeWhere((key, _) {
      final parts = key.split('-');
      if (parts.length != 3) return true;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return d.isBefore(cutoff);
    });

    _box.write(_historyStorageKey, history);
  }

  List<double> _buildScoreHistory(Map<String, dynamic> history, int today) {
    double? lastKnown;
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final key = _dateKey(DateTime.now().subtract(Duration(days: i)));
      final entry = history[key];
      if (entry is Map && entry['overall'] is num) {
        lastKnown = (entry['overall'] as num).toDouble();
      }
      // No record for this day yet: fall back to today's just-computed
      // score rather than inventing a distinct number for it.
      result.add(lastKnown ?? today.toDouble());
    }
    return result;
  }

  List<double> _buildThreatHistory(Map<String, dynamic> history, int today) {
    double? lastKnown;
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final key = _dateKey(DateTime.now().subtract(Duration(days: i)));
      final entry = history[key];
      if (entry is Map && entry['threats'] is num) {
        lastKnown = (entry['threats'] as num).toDouble();
      }
      // No record for this day yet: 0 is the honest default (no evidence
      // of threats), not today's count projected backwards.
      result.add(lastKnown ?? 0);
    }
    return result;
  }

  Future<void> runFullScan() async {
    if (isScanning.value) return;
    isScanning.value = true;

    final wifi = Get.find<WifiShieldController>();
    final privacy = Get.find<PrivacyGuardController>();

    try {
      await Future.wait([
        if (wifi.hasPermission.value) wifi.startScan(),
        privacy.checkPermissions(),
      ]);
      await _recomputeScore();
    } finally {
      isScanning.value = false;
    }

    Get.snackbar(
      'Scan Complete',
      'Security score updated to ${score.value.overall}/100',
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
