import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/shared/models/threat_alert_model.dart';

/// Regression coverage for the audit finding: ThreatIntelService.fetchAlerts()
/// parsed every remote feed element in a single .map().toList(), so one
/// malformed alert threw out of the whole batch and silently fell back to
/// stale cached data, discarding every other valid alert too. The fix wraps
/// each ThreatAlert.fromJson() call individually -- this file verifies the
/// exact conditions that call throws under, since the service itself talks
/// to a real network endpoint with no injection point to mock in a test.
void main() {
  final validJson = {
    'id': 'alert-1',
    'severity': 'high',
    'region': 'global',
    'title': 'Test Alert',
    'description': 'A test alert description',
    'mitre_technique': 'T1566',
    'published_at': '2026-01-01T00:00:00Z',
  };

  test('fromJson parses a well-formed alert', () {
    final alert = ThreatAlert.fromJson(validJson);
    expect(alert.id, 'alert-1');
    expect(alert.severity, AlertSeverity.high);
    expect(alert.region, 'global');
    expect(alert.title, 'Test Alert');
    expect(alert.description, 'A test alert description');
    expect(alert.mitreTechnique, 'T1566');
  });

  test('fromJson falls back to AlertSeverity.low for an unknown severity', () {
    final json = {...validJson, 'severity': 'nonsense'};
    expect(ThreatAlert.fromJson(json).severity, AlertSeverity.low);
  });

  test('fromJson tolerates a missing mitre_technique', () {
    final json = {...validJson}..remove('mitre_technique');
    expect(ThreatAlert.fromJson(json).mitreTechnique, isNull);
  });

  test('fromJson throws when a required field is missing', () {
    final json = {...validJson}..remove('title');
    expect(() => ThreatAlert.fromJson(json), throwsA(anything));
  });

  test('fromJson throws when a required field has the wrong type', () {
    final json = {...validJson, 'id': 42};
    expect(() => ThreatAlert.fromJson(json), throwsA(anything));
  });

  test('fromJson throws for an unparseable published_at', () {
    final json = {...validJson, 'published_at': 'not-a-date'};
    expect(() => ThreatAlert.fromJson(json), throwsA(anything));
  });
}
