import 'package:get_storage/get_storage.dart';

import '../../shared/models/network_trust_record.dart';

/// Persists per-SSID BSSID history so repeat scans can detect a network
/// that has quietly changed its access-point hardware over time — the
/// historical counterpart to the real-time evil-twin analysis in
/// WifiShieldController.
class NetworkTrustService {
  NetworkTrustService._();

  static final NetworkTrustService instance = NetworkTrustService._();

  static const _storageKey = 'network_trust_records';

  final _box = GetStorage();
  final Map<String, NetworkTrustRecord> _records = {};

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _loadPersisted();
  }

  void _loadPersisted() {
    final saved = _box.read<Map<String, dynamic>>(_storageKey);
    if (saved == null) return;
    saved.forEach((key, value) {
      _records[key] =
          NetworkTrustRecord.fromJson(Map<String, dynamic>.from(value as Map));
    });
  }

  void _persist() {
    final json = _records.map((key, record) => MapEntry(key, record.toJson()));
    _box.write(_storageKey, json);
  }

  NetworkTrustRecord recordSighting(String ssid, String bssid) {
    final key = ssid.toLowerCase();
    final now = DateTime.now();
    final existing = _records[key];

    NetworkTrustRecord updated;
    if (existing == null) {
      updated = NetworkTrustRecord(
        ssid: ssid,
        knownBssids: {bssid},
        firstSeenAt: now,
        lastSeenAt: now,
        timesSeen: 1,
      );
    } else if (existing.knownBssids.contains(bssid)) {
      updated = existing.copyWith(
        lastSeenAt: now,
        timesSeen: existing.timesSeen + 1,
        bssidChanged: false,
      );
    } else {
      updated = existing.copyWith(
        knownBssids: {...existing.knownBssids, bssid},
        lastSeenAt: now,
        timesSeen: existing.timesSeen + 1,
        bssidChanged: true,
      );
    }

    _records[key] = updated;
    _persist();
    return updated;
  }

  NetworkTrustRecord? getRecord(String ssid) => _records[ssid.toLowerCase()];

  Map<String, NetworkTrustRecord> getAllRecords() =>
      Map.unmodifiable(_records);
}
