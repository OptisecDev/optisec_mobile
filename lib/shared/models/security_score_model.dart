import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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

/// Score → severity tier boundaries, and what each tier maps to. Single
/// source of truth for the >=80/>=60/>=40 thresholds that used to be
/// hand-copied independently in score_ring.dart, score_history_chart.dart,
/// security_report_pdf_service.dart, and privacy_guard_view.dart.
enum ScoreTier { safe, good, warning, critical }

ScoreTier scoreTierFor(int score) {
  if (score >= 80) return ScoreTier.safe;
  if (score >= 60) return ScoreTier.good;
  if (score >= 40) return ScoreTier.warning;
  return ScoreTier.critical;
}

Color scoreColorFor(int score) {
  switch (scoreTierFor(score)) {
    case ScoreTier.safe:
      return AppColors.safe;
    case ScoreTier.good:
      return AppColors.primary;
    case ScoreTier.warning:
      return AppColors.warning;
    case ScoreTier.critical:
      return AppColors.danger;
  }
}

String scoreStatusLabelFor(int score) {
  switch (scoreTierFor(score)) {
    case ScoreTier.safe:
      return 'Excellent';
    case ScoreTier.good:
      return 'Good';
    case ScoreTier.warning:
      return 'Fair';
    case ScoreTier.critical:
      return 'Critical';
  }
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

  String get statusLabel => scoreStatusLabelFor(overall);

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
