enum WifiSecurity { open, wep, wpa, wpa2, wpa3, unknown }

enum ThreatLevel { safe, warning, danger }

enum EvilTwinReason {
  differentOui,       // Same SSID, different vendor prefix
  securityDowngrade,  // Same SSID but weaker encryption
  signalAnomaly,      // Unusually strong hidden network
  openImpersonation,  // Open clone of a secured network
}

class WifiNetworkModel {
  final String ssid;
  final String bssid;
  final int level; // dBm
  final int frequency; // MHz
  final WifiSecurity security;
  final ThreatLevel threatLevel;
  final bool isConnected;
  final List<String> threats;
  final int riskScore; // 0-100, higher = riskier
  final bool isEvilTwin;
  final List<EvilTwinReason> evilTwinReasons;

  const WifiNetworkModel({
    required this.ssid,
    required this.bssid,
    required this.level,
    required this.frequency,
    required this.security,
    required this.threatLevel,
    this.isConnected = false,
    this.threats = const [],
    this.riskScore = 0,
    this.isEvilTwin = false,
    this.evilTwinReasons = const [],
  });

  int get signalPercent => ((level + 100) / 60 * 100).clamp(0, 100).toInt();

  int get channel {
    if (frequency >= 2412 && frequency <= 2484) {
      return ((frequency - 2412) / 5 + 1).round();
    } else if (frequency >= 5170 && frequency <= 5825) {
      return ((frequency - 5170) / 5 + 34).round();
    }
    return 0;
  }

  String get band => frequency >= 5000 ? '5 GHz' : '2.4 GHz';

  String get oui => bssid.isNotEmpty && bssid.length >= 8
      ? bssid.substring(0, 8).toUpperCase()
      : '??:??:??';

  String get securityLabel {
    switch (security) {
      case WifiSecurity.open:
        return 'Open';
      case WifiSecurity.wep:
        return 'WEP';
      case WifiSecurity.wpa:
        return 'WPA';
      case WifiSecurity.wpa2:
        return 'WPA2';
      case WifiSecurity.wpa3:
        return 'WPA3';
      case WifiSecurity.unknown:
        return 'Unknown';
    }
  }

  String get riskLabel {
    if (riskScore >= 70) return 'Critical';
    if (riskScore >= 45) return 'High';
    if (riskScore >= 20) return 'Medium';
    return 'Low';
  }

  WifiNetworkModel copyWith({
    String? ssid,
    String? bssid,
    int? level,
    int? frequency,
    WifiSecurity? security,
    ThreatLevel? threatLevel,
    bool? isConnected,
    List<String>? threats,
    int? riskScore,
    bool? isEvilTwin,
    List<EvilTwinReason>? evilTwinReasons,
  }) {
    return WifiNetworkModel(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      level: level ?? this.level,
      frequency: frequency ?? this.frequency,
      security: security ?? this.security,
      threatLevel: threatLevel ?? this.threatLevel,
      isConnected: isConnected ?? this.isConnected,
      threats: threats ?? this.threats,
      riskScore: riskScore ?? this.riskScore,
      isEvilTwin: isEvilTwin ?? this.isEvilTwin,
      evilTwinReasons: evilTwinReasons ?? this.evilTwinReasons,
    );
  }
}
