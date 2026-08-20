import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../core/services/network_trust_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/wifi_network_model.dart';
import '../../subscription/controllers/subscription_controller.dart';

enum SortMode { signal, risk, name }

enum FilterMode { all, safe, threats, evilTwin }

/// How confidently a same-SSID vendor-prefix mismatch indicates a real
/// attack rather than a legitimate dual-band router or mesh deployment.
/// Kept private/internal for now: it drives risk score and threat-level
/// severity below, but there is no dedicated UI copy for it yet (that's a
/// separate follow-up outside this fix's scope).
enum _OuiMismatchConfidence { low, medium, high }

class WifiShieldController extends GetxController with WidgetsBindingObserver {
  final _allNetworks = <WifiNetworkModel>[];

  final networks = <WifiNetworkModel>[].obs;
  final isScanning = false.obs;
  final hasPermission = false.obs;
  final connectedSsid = ''.obs;
  final connectedIp = ''.obs;
  final connectedGateway = ''.obs;
  final scanError = ''.obs;
  final evilTwinDismissed = false.obs;

  final sortMode = SortMode.signal.obs;
  final filterMode = FilterMode.all.obs;

  final _networkInfo = NetworkInfo();
  final _box = GetStorage();

  static const _dailyScanDateKey = 'wifi_scan_date';
  static const _dailyScanCountKey = 'wifi_scan_count';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The permission may have been changed from system Settings while the
    // app was backgrounded (granted, to unlock scanning; or revoked, which
    // must immediately re-lock the UI behind the permission gate) -- without
    // this, hasPermission stays stale until a full app restart.
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndInit();
    }
  }

  Future<void> _checkPermissionAndInit() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        final wasAlreadyGranted = hasPermission.value;
        hasPermission.value = true;
        await _loadConnectedInfo();
        if (!wasAlreadyGranted) {
          await startScan();
        }
      } else {
        hasPermission.value = false;
      }
    } catch (_) {
      hasPermission.value = false;
    }
  }

  Future<void> requestPermission() async {
    try {
      final result = await Permission.locationWhenInUse.request();
      if (result.isGranted) {
        hasPermission.value = true;
        await _loadConnectedInfo();
        await startScan();
      }
    } catch (_) {
      hasPermission.value = false;
    }
  }

  Future<void> _loadConnectedInfo() async {
    try {
      connectedSsid.value =
          (await _networkInfo.getWifiName() ?? '').replaceAll('"', '');
      connectedIp.value = await _networkInfo.getWifiIP() ?? '';
      connectedGateway.value = await _networkInfo.getWifiGatewayIP() ?? '';
    } catch (_) {}
  }

  Future<void> startScan() async {
    if (isScanning.value || !hasPermission.value) return;

    final subscriptionController = Get.find<SubscriptionController>();
    if (!subscriptionController.isPro &&
        _todayScanCount() >= FeatureGate.freeScansPerDay) {
      subscriptionController.checkAccessOrPrompt(
          feature: AppLocalizations.of(Get.context!).wifiUnlimitedScansFeature);
      return;
    }

    isScanning.value = true;
    scanError.value = '';
    evilTwinDismissed.value = false;

    try {
      final canScan =
          await WiFiScan.instance.canStartScan(askPermissions: true);
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        await Future.delayed(const Duration(seconds: 3));
        final canGet = await WiFiScan.instance
            .canGetScannedResults(askPermissions: true);
        if (canGet == CanGetScannedResults.yes) {
          final results = await WiFiScan.instance.getScannedResults();
          final mapped = results.map(_mapResult).toList();

          // Historical evil-twin signal: has this SSID gained a BSSID that
          // wasn't known before this scan? Grouped by SSID and recorded in
          // one batch per SSID so a network broadcasting several BSSIDs at
          // once (dual-band router, mesh system) isn't flagged just because
          // its other BSSIDs happen to be processed after the first.
          // Recorded before the real-time analysis below and fed into it as
          // one of the confidence signals for vendor-prefix mismatches -- a
          // brand-new BSSID from an unfamiliar vendor appearing after the
          // network was already stable is a much stronger attack signal
          // than several vendors being present together from the very first
          // scan (the normal dual-band/mesh pattern).
          final historicalChange = <String, bool>{}; // bssid -> bssidChanged
          final bssidsBySsid = <String, Set<String>>{};
          for (final n in mapped) {
            bssidsBySsid.putIfAbsent(n.ssid, () => {}).add(n.bssid);
          }
          bssidsBySsid.forEach((ssid, bssids) {
            historicalChange.addAll(
                NetworkTrustService.instance.recordSightingBatch(ssid, bssids));
          });

          final evaluated = _runEvilTwinAnalysis(mapped, historicalChange);
          final l10n = AppLocalizations.of(Get.context!);
          _allNetworks
            ..clear()
            ..addAll(evaluated.map((n) {
              if (historicalChange[n.bssid] != true) return n;
              return n.copyWith(
                isEvilTwin: true,
                evilTwinReasons: [
                  ...n.evilTwinReasons,
                  EvilTwinReason.historicalBssidChange,
                ],
                threats: [
                  ...n.threats,
                  l10n.wifiThreatHistoricalChange(n.ssid),
                ],
                riskScore: (n.riskScore + 40).clamp(0, 100),
                threatLevel: ThreatLevel.danger,
              );
            }));
          _applyFiltersAndSort();
          if (!subscriptionController.isPro) {
            _incrementTodayScanCount();
          }
        }
      }
    } catch (e) {
      scanError.value = e.toString();
    } finally {
      isScanning.value = false;
    }
  }

  // ─── Daily free-tier scan limit ──────────────────────────────────────────

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  int _todayScanCount() {
    final savedDate = _box.read<String>(_dailyScanDateKey);
    if (savedDate != _todayKey) {
      _box.write(_dailyScanDateKey, _todayKey);
      _box.write(_dailyScanCountKey, 0);
      return 0;
    }
    return _box.read<int>(_dailyScanCountKey) ?? 0;
  }

  void _incrementTodayScanCount() {
    final count = _todayScanCount();
    _box.write(_dailyScanDateKey, _todayKey);
    _box.write(_dailyScanCountKey, count + 1);
  }

  // ─── Mapping ─────────────────────────────────────────────────────────────

  WifiNetworkModel _mapResult(WiFiAccessPoint ap) {
    final security = _parseSecurity(ap.capabilities);
    final threats = _baseThreats(ap, security);
    return WifiNetworkModel(
      ssid: ap.ssid.isEmpty ? '(Hidden Network)' : ap.ssid,
      bssid: ap.bssid,
      level: ap.level,
      frequency: ap.frequency,
      security: security,
      threatLevel: ThreatLevel.safe, // recalculated after evil twin pass
      isConnected: ap.ssid == connectedSsid.value,
      threats: threats,
    );
  }

  WifiSecurity _parseSecurity(String? caps) {
    if (caps == null || caps.isEmpty) return WifiSecurity.open;
    if (caps.contains('WPA3')) return WifiSecurity.wpa3;
    if (caps.contains('WPA2')) return WifiSecurity.wpa2;
    if (caps.contains('WPA')) return WifiSecurity.wpa;
    if (caps.contains('WEP')) return WifiSecurity.wep;
    return WifiSecurity.open;
  }

  List<String> _baseThreats(WiFiAccessPoint ap, WifiSecurity sec) {
    final l10n = AppLocalizations.of(Get.context!);
    final t = <String>[];
    if (sec == WifiSecurity.open) {
      t.add(l10n.wifiThreatOpenNetwork);
    }
    if (sec == WifiSecurity.wep) {
      t.add(l10n.wifiThreatWepBroken);
    }
    return t;
  }

  // ─── Evil Twin Analysis ──────────────────────────────────────────────────

  List<WifiNetworkModel> _runEvilTwinAnalysis(
      List<WifiNetworkModel> raw, Map<String, bool> historicalChange) {
    // Group by SSID (case-insensitive, skip hidden)
    final Map<String, List<WifiNetworkModel>> bySsid = {};
    for (final n in raw) {
      if (n.ssid == '(Hidden Network)') continue;
      bySsid.putIfAbsent(n.ssid.toLowerCase(), () => []).add(n);
    }

    final updated = <WifiNetworkModel>[];
    for (final n in raw) {
      updated.add(_evaluate(
        n,
        bySsid[n.ssid.toLowerCase()] ?? [n],
        historicalChange[n.bssid] ?? false,
      ));
    }
    return updated;
  }

  WifiNetworkModel _evaluate(
      WifiNetworkModel n, List<WifiNetworkModel> peers, bool isHistoricallyNew) {
    final l10n = AppLocalizations.of(Get.context!);
    final reasons = <EvilTwinReason>[];
    final threats = List<String>.from(n.threats);
    int risk = _baseRiskScore(n);

    // Unlike the other signals below, an OUI mismatch alone is graduated by
    // confidence instead of always forcing ThreatLevel.danger -- range
    // extenders and mesh nodes legitimately broadcast the same SSID from a
    // different manufacturer's hardware than the primary router.
    var forceDanger = false;
    var forceWarning = false;

    if (peers.length > 1) {
      final others = peers.where((p) => p.bssid != n.bssid).toList();
      final mismatched = others.where((o) => o.oui != n.oui).toList();

      if (mismatched.isNotEmpty) {
        switch (_ouiMismatchConfidence(n, mismatched, isHistoricallyNew)) {
          case _OuiMismatchConfidence.high:
            reasons.add(EvilTwinReason.differentOui);
            threats.add(l10n.wifiThreatMultipleVendors(n.ssid));
            risk += 50;
            forceDanger = true;
            break;
          case _OuiMismatchConfidence.medium:
            reasons.add(EvilTwinReason.differentOui);
            threats.add(l10n.wifiThreatMultipleVendors(n.ssid));
            risk += 25;
            forceWarning = true;
            break;
          case _OuiMismatchConfidence.low:
            // Matches the normal dual-band/mesh pattern closely enough that
            // it isn't worth flagging as an evil twin off OUI alone.
            risk += 5;
            break;
        }
      }

      // Security downgrade: one AP is open while another with same SSID is secured
      final hasSecured = peers.any((p) => p.security != WifiSecurity.open);
      final hasOpen = peers.any((p) => p.security == WifiSecurity.open);
      if (hasSecured && hasOpen && n.security == WifiSecurity.open) {
        reasons.add(EvilTwinReason.openImpersonation);
        threats.add(l10n.wifiThreatOpenClone(n.ssid));
        risk += 60;
        forceDanger = true;
      }

      // Security downgrade: WPA2 elsewhere, WEP/WPA here
      final maxSec = peers.map((p) => _securityRank(p.security)).reduce((a, b) => a > b ? a : b);
      if (_securityRank(n.security) < maxSec - 1) {
        reasons.add(EvilTwinReason.securityDowngrade);
        threats.add(l10n.wifiThreatWeakerEncryption(n.ssid));
        risk += 30;
        forceDanger = true;
      }
    }

    // Hidden network with unusually strong signal
    if (n.ssid == '(Hidden Network)' && n.level > -50) {
      reasons.add(EvilTwinReason.signalAnomaly);
      threats.add(l10n.wifiThreatHiddenStrongSignal);
      risk += 25;
      forceDanger = true;
    }

    risk = risk.clamp(0, 100);

    final isEvilTwin = reasons.isNotEmpty;
    final threatLevel = forceDanger
        ? ThreatLevel.danger
        : forceWarning || risk >= 40
            ? ThreatLevel.warning
            : ThreatLevel.safe;

    return n.copyWith(
      threats: threats,
      riskScore: risk,
      isEvilTwin: isEvilTwin,
      evilTwinReasons: reasons,
      threatLevel: threatLevel,
    );
  }

  /// Scores how likely a same-SSID vendor-prefix mismatch is a genuine
  /// attack rather than a legitimate dual-band router or mesh deployment,
  /// using the corroborating signals a range extender/mesh node produces
  /// naturally but a co-located rogue AP can't easily fake:
  ///
  /// - Band/channel separation: real dual-band APs broadcast the same SSID
  ///   on clearly different frequencies (2.4GHz + 5GHz) at once; several
  ///   different-vendor BSSIDs sharing the *exact* same channel is a much
  ///   stronger red flag.
  /// - Relative signal strength: mesh nodes are physically separated, so
  ///   their signal strengths naturally diverge; two different-vendor BSSIDs
  ///   reporting near-identical strength at the same moment looks more like
  ///   a nearby impersonating device.
  /// - Timing: a different-vendor BSSID that just appeared after this SSID
  ///   was already established with other hardware ([isHistoricallyNew],
  ///   from [NetworkTrustService.recordSightingBatch]) is far more
  ///   suspicious than several vendors being present together from the very
  ///   first scan.
  _OuiMismatchConfidence _ouiMismatchConfidence(
    WifiNetworkModel n,
    List<WifiNetworkModel> mismatchedPeers,
    bool isHistoricallyNew,
  ) {
    var points = 2; // baseline: an unexplained vendor mismatch is ambiguous

    var sawDifferentBand = false;
    var sawSameChannel = false;
    var sawCloseSignal = false;
    var sawSeparatedSignal = false;

    for (final other in mismatchedPeers) {
      if (n.band != other.band) {
        sawDifferentBand = true;
      } else if (n.channel == other.channel) {
        sawSameChannel = true;
      }

      final signalGap = (n.level - other.level).abs();
      if (signalGap <= 5) {
        sawCloseSignal = true;
      } else if (signalGap > 15) {
        sawSeparatedSignal = true;
      }
    }

    if (sawDifferentBand) points -= 2;
    if (sawSameChannel) points += 2;
    if (sawSeparatedSignal) points -= 1;
    if (sawCloseSignal) points += 1;
    if (isHistoricallyNew) points += 3;

    if (points >= 4) return _OuiMismatchConfidence.high;
    if (points >= 1) return _OuiMismatchConfidence.medium;
    return _OuiMismatchConfidence.low;
  }

  int _baseRiskScore(WifiNetworkModel n) {
    int score = 0;
    if (n.security == WifiSecurity.open) score += 40;
    if (n.security == WifiSecurity.wep) score += 30;
    if (n.security == WifiSecurity.wpa) score += 10;
    return score;
  }

  int _securityRank(WifiSecurity s) {
    switch (s) {
      case WifiSecurity.open:
        return 0;
      case WifiSecurity.wep:
        return 1;
      case WifiSecurity.wpa:
        return 2;
      case WifiSecurity.wpa2:
        return 3;
      case WifiSecurity.wpa3:
        return 4;
      case WifiSecurity.unknown:
        return 0;
    }
  }

  // ─── Filters & Sort ──────────────────────────────────────────────────────

  void setFilter(FilterMode mode) {
    filterMode.value = mode;
    _applyFiltersAndSort();
  }

  void setSort(SortMode mode) {
    sortMode.value = mode;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var list = List<WifiNetworkModel>.from(_allNetworks);

    switch (filterMode.value) {
      case FilterMode.all:
        break;
      case FilterMode.safe:
        list = list.where((n) => n.threatLevel == ThreatLevel.safe).toList();
        break;
      case FilterMode.threats:
        list = list.where((n) => n.threatLevel != ThreatLevel.safe).toList();
        break;
      case FilterMode.evilTwin:
        list = list.where((n) => n.isEvilTwin).toList();
        break;
    }

    switch (sortMode.value) {
      case SortMode.signal:
        list.sort((a, b) => b.level.compareTo(a.level));
        break;
      case SortMode.risk:
        list.sort((a, b) => b.riskScore.compareTo(a.riskScore));
        break;
      case SortMode.name:
        list.sort((a, b) => a.ssid.compareTo(b.ssid));
        break;
    }

    networks.value = list;
  }

  void dismissEvilTwinAlert() => evilTwinDismissed.value = true;

  // ─── Derived ─────────────────────────────────────────────────────────────

  bool get hasEvilTwin => _allNetworks.any((n) => n.isEvilTwin);
  List<WifiNetworkModel> get evilTwins =>
      _allNetworks.where((n) => n.isEvilTwin).toList();

  WifiNetworkModel? get connectedNetwork =>
      _allNetworks.firstWhereOrNull((n) => n.isConnected);

  int get safeCount =>
      _allNetworks.where((n) => n.threatLevel == ThreatLevel.safe).length;
  int get threatCount =>
      _allNetworks.where((n) => n.threatLevel != ThreatLevel.safe).length;
  int get evilTwinCount => _allNetworks.where((n) => n.isEvilTwin).length;

  int get overallRisk {
    if (_allNetworks.isEmpty) return 0;
    // Evil-twin networks already carry a higher riskScore (see _evaluate),
    // so the graduated max below reflects their severity without a
    // hardcoded floor that ignored how many/how severe the flags were.
    if (threatCount > 0) {
      final maxRisk =
          _allNetworks.map((n) => n.riskScore).reduce((a, b) => a > b ? a : b);
      return maxRisk;
    }
    return 10;
  }
}
