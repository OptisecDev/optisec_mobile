enum AlertSeverity { low, medium, high, critical }

class ThreatAlert {
  final String id;
  final AlertSeverity severity;
  final String region;
  final String title;
  final String description;
  final String? mitreTechnique;
  final DateTime publishedAt;

  const ThreatAlert({
    required this.id,
    required this.severity,
    required this.region,
    required this.title,
    required this.description,
    this.mitreTechnique,
    required this.publishedAt,
  });

  factory ThreatAlert.fromJson(Map<String, dynamic> json) {
    return ThreatAlert(
      id: json['id'] as String,
      severity: AlertSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      region: json['region'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mitreTechnique: json['mitre_technique'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'severity': severity.name,
        'region': region,
        'title': title,
        'description': description,
        'mitre_technique': mitreTechnique,
        'published_at': publishedAt.toIso8601String(),
      };
}
