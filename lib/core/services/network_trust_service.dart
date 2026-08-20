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
    final changed = recordSightingBatch(ssid, {bssid});
    return _records[ssid.toLowerCase()]!.copyWith(
      bssidChanged: changed[bssid] ?? false,
    );
  }

  /// Records every BSSID seen for [ssid] in a single scan pass, compared as
  /// one batch against what was known *before* this scan. Returns, per
  /// BSSID, whether it is genuinely new relative to that prior state.
  ///
  /// A network broadcasting multiple BSSIDs at once (dual-band router, mesh
  /// system) must not have its later BSSIDs flagged as a historical change
  /// just because they're processed after the first one within the same
  /// scan -- that previously misclassified ordinary multi-AP networks as
  /// evil twins on their very first scan.
  Map<String, bool> recordSightingBatch(String ssid, Set<String> bssids) {
    final key = ssid.toLowerCase();
    final now = DateTime.now();
    final existing = _records[key];
    final previouslyKnown = existing?.knownBssids ?? const <String>{};

    final changed = <String, bool>{
      for (final bssid in bssids)
        bssid: existing != null && !previouslyKnown.contains(bssid),
    };

    final updated = existing == null
        ? NetworkTrustRecord(
            ssid: ssid,
            knownBssids: bssids,
            firstSeenAt: now,
            lastSeenAt: now,
            timesSeen: 1,
          )
        : existing.copyWith(
            knownBssids: {...previouslyKnown, ...bssids},
            lastSeenAt: now,
            timesSeen: existing.timesSeen + 1,
            bssidChanged: changed.values.any((v) => v),
          );

    _records[key] = updated;
    _persist();
    return changed;
  }

  NetworkTrustRecord? getRecord(String ssid) => _records[ssid.toLowerCase()];

  Map<String, NetworkTrustRecord> getAllRecords() =>
      Map.unmodifiable(_records);
}
