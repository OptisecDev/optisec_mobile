import 'dart:convert';
import 'dart:typed_data';

/// A launchable app returned by the native App Lock picker, with its icon
/// pre-encoded as PNG bytes so the list can render without a second native
/// round-trip per row.
class InstalledAppInfo {
  final String packageName;
  final String appName;
  final Uint8List? iconBytes;

  const InstalledAppInfo({
    required this.packageName,
    required this.appName,
    this.iconBytes,
  });

  factory InstalledAppInfo.fromJson(Map<String, dynamic> json) {
    final icon = json['icon'] as String?;
    return InstalledAppInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      iconBytes: icon == null ? null : base64Decode(icon),
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
      };
}
