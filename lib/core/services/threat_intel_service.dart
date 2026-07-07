import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../shared/models/threat_alert_model.dart';

/// Fetches a published threat-intel feed and caches the last successful
/// result in GetStorage so the app has something to show offline. Never
/// throws — callers always get cached data (or an empty list) even if the
/// network request fails or the feed is malformed.
class ThreatIntelService {
  ThreatIntelService._();

  static final ThreatIntelService instance = ThreatIntelService._();

  // REPLACE with your raw.githubusercontent.com URL once the feed file is
  // published, e.g.
  // 'https://raw.githubusercontent.com/<org>/<repo>/main/threat_feed.json'
  static const String feedUrl =
      'https://example.com/REPLACE_ME/threat_feed.json';

  static const _alertsStorageKey = 'threat_intel_alerts';
  static const _updatedAtStorageKey = 'threat_intel_updated_at';
  static const _fetchedAtStorageKey = 'threat_intel_fetched_at';

  final _box = GetStorage();

  List<ThreatAlert> _cachedAlerts = [];
  DateTime? _updatedAt;
  DateTime? _fetchedAt;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _loadPersisted();
  }

  void _loadPersisted() {
    final savedAlerts = _box.read<List>(_alertsStorageKey);
    if (savedAlerts != null) {
      _cachedAlerts = savedAlerts
          .map((e) =>
              ThreatAlert.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final savedUpdatedAt = _box.read<String>(_updatedAtStorageKey);
    if (savedUpdatedAt != null) _updatedAt = DateTime.tryParse(savedUpdatedAt);

    final savedFetchedAt = _box.read<String>(_fetchedAtStorageKey);
    if (savedFetchedAt != null) _fetchedAt = DateTime.tryParse(savedFetchedAt);
  }

  void _persist(
    List<ThreatAlert> alerts,
    DateTime updatedAt,
    DateTime fetchedAt,
  ) {
    _box.write(_alertsStorageKey, alerts.map((a) => a.toJson()).toList());
    _box.write(_updatedAtStorageKey, updatedAt.toIso8601String());
    _box.write(_fetchedAtStorageKey, fetchedAt.toIso8601String());
  }

  /// When the feed itself says it was last updated (falls back to fetch
  /// time if the feed doesn't include one).
  DateTime? get updatedAt => _updatedAt;

  Future<List<ThreatAlert>> fetchAlerts({bool forceRefresh = false}) async {
    if (!_initialized) await init();

    final isFresh = _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(hours: 1);
    if (!forceRefresh && isFresh && _cachedAlerts.isNotEmpty) {
      return _cachedAlerts;
    }

    try {
      final response = await http
          .get(Uri.parse(feedUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return _cachedAlerts;

      final decoded = jsonDecode(response.body);

      final List<dynamic> alertsJson;
      final DateTime updatedAt;

      if (decoded is Map<String, dynamic>) {
        alertsJson = decoded['alerts'] as List<dynamic>? ?? [];
        final rawUpdatedAt = decoded['updated_at'] as String?;
        updatedAt = rawUpdatedAt != null
            ? DateTime.tryParse(rawUpdatedAt) ?? DateTime.now()
            : DateTime.now();
      } else if (decoded is List) {
        alertsJson = decoded;
        updatedAt = DateTime.now();
      } else {
        return _cachedAlerts;
      }

      final alerts = alertsJson
          .map((e) =>
              ThreatAlert.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final fetchedAt = DateTime.now();
      _cachedAlerts = alerts;
      _updatedAt = updatedAt;
      _fetchedAt = fetchedAt;
      _persist(alerts, updatedAt, fetchedAt);

      return _cachedAlerts;
    } catch (_) {
      return _cachedAlerts;
    }
  }
}
