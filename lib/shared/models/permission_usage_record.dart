/// A record of foreground app time for an app holding a tracked permission.
/// This reflects when the app was in the foreground, not confirmed sensor
/// access — see [PermissionUsageService].
class PermissionUsageRecord {
  final String packageName;
  final String appLabel;
  final String permissionType; // 'CAMERA' | 'MICROPHONE' | 'LOCATION'
  final DateTime? lastForegroundTime;
  final bool isCurrentlyInForeground;
  final int foregroundSessionCountLast7Days;

  const PermissionUsageRecord({
    required this.packageName,
    required this.appLabel,
    required this.permissionType,
    this.lastForegroundTime,
    required this.isCurrentlyInForeground,
    required this.foregroundSessionCountLast7Days,
  });

  factory PermissionUsageRecord.fromJson(Map<String, dynamic> json) {
    return PermissionUsageRecord(
      packageName: json['packageName'] as String,
      appLabel: json['appLabel'] as String,
      permissionType: json['permissionType'] as String,
      lastForegroundTime: json['lastForegroundTime'] == null
          ? null
          : DateTime.parse(json['lastForegroundTime'] as String),
      isCurrentlyInForeground:
          json['isCurrentlyInForeground'] as bool? ?? false,
      foregroundSessionCountLast7Days:
          json['foregroundSessionCountLast7Days'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appLabel': appLabel,
        'permissionType': permissionType,
        'lastForegroundTime': lastForegroundTime?.toIso8601String(),
        'isCurrentlyInForeground': isCurrentlyInForeground,
        'foregroundSessionCountLast7Days': foregroundSessionCountLast7Days,
      };
}
