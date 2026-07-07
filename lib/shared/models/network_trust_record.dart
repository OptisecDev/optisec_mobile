class NetworkTrustRecord {
  final String ssid;
  final Set<String> knownBssids;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final int timesSeen;
  final bool bssidChanged;

  const NetworkTrustRecord({
    required this.ssid,
    required this.knownBssids,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.timesSeen,
    this.bssidChanged = false,
  });

  /// 50 for a brand-new SSID, +2 per additional sighting with a
  /// previously-known BSSID (capped at 100). A previously-unseen BSSID
  /// appearing for an SSID with existing known BSSIDs is the historical
  /// evil-twin signal and hard-overrides the score to 10.
  int get trustScore {
    if (bssidChanged) return 10;
    return (50 + (timesSeen - 1) * 2).clamp(0, 100);
  }

  NetworkTrustRecord copyWith({
    String? ssid,
    Set<String>? knownBssids,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    int? timesSeen,
    bool? bssidChanged,
  }) {
    return NetworkTrustRecord(
      ssid: ssid ?? this.ssid,
      knownBssids: knownBssids ?? this.knownBssids,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      timesSeen: timesSeen ?? this.timesSeen,
      bssidChanged: bssidChanged ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'knownBssids': knownBssids.toList(),
        'firstSeenAt': firstSeenAt.toIso8601String(),
        'lastSeenAt': lastSeenAt.toIso8601String(),
        'timesSeen': timesSeen,
        'bssidChanged': bssidChanged,
      };

  factory NetworkTrustRecord.fromJson(Map<String, dynamic> json) {
    return NetworkTrustRecord(
      ssid: json['ssid'] as String,
      knownBssids: Set<String>.from(
          (json['knownBssids'] as List?)?.cast<String>() ?? const []),
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      timesSeen: json['timesSeen'] as int? ?? 1,
      bssidChanged: json['bssidChanged'] as bool? ?? false,
    );
  }
}
