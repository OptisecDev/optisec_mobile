enum ThreatSeverity { low, medium, high, critical }

class ThreatItem {
  final String id;
  final String title;
  final String description;
  final ThreatSeverity severity;
  final String category; // 'wifi' | 'privacy' | 'app'
  final DateTime detectedAt;

  const ThreatItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.detectedAt,
  });
}

class SecurityScoreModel {
  final int overall;
  final int wifiScore;
  final int privacyScore;
  final int appScore;
  final int threatsDetected;
  final int networksScanned;
  final DateTime lastScan;
  final int scoreDelta;          // change vs. previous scan (+/-)
  final List<ThreatItem> threats;

  const SecurityScoreModel({
    required this.overall,
    required this.wifiScore,
    required this.privacyScore,
    required this.appScore,
    required this.threatsDetected,
    required this.networksScanned,
    required this.lastScan,
    this.scoreDelta = 0,
    this.threats = const [],
  });

  factory SecurityScoreModel.initial() => SecurityScoreModel(
        overall: 0,
        wifiScore: 0,
        privacyScore: 0,
        appScore: 0,
        threatsDetected: 0,
        networksScanned: 0,
        lastScan: DateTime.now(),
      );

  String get statusLabel {
    if (overall >= 80) return 'Excellent';
    if (overall >= 60) return 'Good';
    if (overall >= 40) return 'Fair';
    return 'Critical';
  }

  SecurityScoreModel copyWith({
    int? overall,
    int? wifiScore,
    int? privacyScore,
    int? appScore,
    int? threatsDetected,
    int? networksScanned,
    DateTime? lastScan,
    int? scoreDelta,
    List<ThreatItem>? threats,
  }) {
    return SecurityScoreModel(
      overall: overall ?? this.overall,
      wifiScore: wifiScore ?? this.wifiScore,
      privacyScore: privacyScore ?? this.privacyScore,
      appScore: appScore ?? this.appScore,
      threatsDetected: threatsDetected ?? this.threatsDetected,
      networksScanned: networksScanned ?? this.networksScanned,
      lastScan: lastScan ?? this.lastScan,
      scoreDelta: scoreDelta ?? this.scoreDelta,
      threats: threats ?? this.threats,
    );
  }
}
