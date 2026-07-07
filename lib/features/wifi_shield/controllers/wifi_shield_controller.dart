import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/wifi_network_model.dart';
import '../../subscription/controllers/subscription_controller.dart';

enum SortMode { signal, risk, name }

enum FilterMode { all, safe, threats, evilTwin }

class WifiShieldController extends GetxController {
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
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        hasPermission.value = true;
        await _loadConnectedInfo();
        await startScan();
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
          feature: 'Unlimited WiFi scans');
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
          _allNetworks
            ..clear()
            ..addAll(_runEvilTwinAnalysis(mapped));
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
    final t = <String>[];
    if (sec == WifiSecurity.open) {
      t.add('Open network — traffic is unencrypted');
    }
    if (sec == WifiSecurity.wep) {
      t.add('WEP encryption is cryptographically broken');
    }
    return t;
  }

  // ─── Evil Twin Analysis ──────────────────────────────────────────────────

  List<WifiNetworkModel> _runEvilTwinAnalysis(List<WifiNetworkModel> raw) {
    // Group by SSID (case-insensitive, skip hidden)
    final Map<String, List<WifiNetworkModel>> bySsid = {};
    for (final n in raw) {
      if (n.ssid == '(Hidden Network)') continue;
      bySsid.putIfAbsent(n.ssid.toLowerCase(), () => []).add(n);
    }

    final updated = <WifiNetworkModel>[];
    for (final n in raw) {
      updated.add(_evaluate(n, bySsid[n.ssid.toLowerCase()] ?? [n]));
    }
    return updated;
  }

  WifiNetworkModel _evaluate(
      WifiNetworkModel n, List<WifiNetworkModel> peers) {
    final reasons = <EvilTwinReason>[];
    final threats = List<String>.from(n.threats);
    int risk = _baseRiskScore(n);

    if (peers.length > 1) {
      final others = peers.where((p) => p.bssid != n.bssid).toList();

      for (final other in others) {
        // Different OUI (vendor prefix) for same SSID
        if (n.oui != other.oui) {
          reasons.add(EvilTwinReason.differentOui);
          threats.add(
              'Multiple vendors broadcasting "${n.ssid}" — possible Evil Twin');
          risk += 50;
          break;
        }
      }

      // Security downgrade: one AP is open while another with same SSID is secured
      final hasSecured = peers.any((p) => p.security != WifiSecurity.open);
      final hasOpen = peers.any((p) => p.security == WifiSecurity.open);
      if (hasSecured && hasOpen && n.security == WifiSecurity.open) {
        reasons.add(EvilTwinReason.openImpersonation);
        threats.add(
            'Open clone of secured network "${n.ssid}" — honeypot suspected');
        risk += 60;
      }

      // Security downgrade: WPA2 elsewhere, WEP/WPA here
      final maxSec = peers.map((p) => _securityRank(p.security)).reduce((a, b) => a > b ? a : b);
      if (_securityRank(n.security) < maxSec - 1) {
        reasons.add(EvilTwinReason.securityDowngrade);
        threats.add('Weaker encryption than other "${n.ssid}" APs');
        risk += 30;
      }
    }

    // Hidden network with unusually strong signal
    if (n.ssid == '(Hidden Network)' && n.level > -50) {
      reasons.add(EvilTwinReason.signalAnomaly);
      threats.add('Hidden AP with very strong signal — possible rogue device');
      risk += 25;
    }

    risk = risk.clamp(0, 100);

    final isEvilTwin = reasons.isNotEmpty;
    final threatLevel = isEvilTwin
        ? ThreatLevel.danger
        : risk >= 40
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
    if (evilTwinCount > 0) return 85;
    if (threatCount > 0) {
      final maxRisk =
          _allNetworks.map((n) => n.riskScore).reduce((a, b) => a > b ? a : b);
      return maxRisk;
    }
    return 10;
  }
}
