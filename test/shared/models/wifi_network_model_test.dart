import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/shared/models/wifi_network_model.dart';

/// Regression test for the audit finding: channel 14 (2484MHz) sits 12MHz
/// above channel 13 (2472MHz), not the usual 5MHz spacing used by every
/// other 2.4GHz channel, so the old linear formula computed channel 15
/// for it instead of 14.
WifiNetworkModel _network({required int frequency}) => WifiNetworkModel(
      ssid: 'test',
      bssid: 'AA:BB:CC:DD:EE:FF',
      level: -50,
      frequency: frequency,
      security: WifiSecurity.wpa2,
      threatLevel: ThreatLevel.safe,
    );

void main() {
  group('channel', () {
    test('2.4GHz channel 1 (2412MHz)', () {
      expect(_network(frequency: 2412).channel, 1);
    });

    test('2.4GHz channel 13 (2472MHz)', () {
      expect(_network(frequency: 2472).channel, 13);
    });

    test('2.4GHz channel 14 (2484MHz) is 14, not 15', () {
      expect(_network(frequency: 2484).channel, 14);
    });

    test('5GHz channel 36 (5180MHz)', () {
      expect(_network(frequency: 5180).channel, 36);
    });

    test('unrecognized frequency returns 0', () {
      expect(_network(frequency: 1000).channel, 0);
    });
  });
}
