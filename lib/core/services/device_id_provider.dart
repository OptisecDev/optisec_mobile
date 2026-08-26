import 'package:flutter/services.dart';

/// Source of a stable per-device identifier, used by [LicenseDeviceBinding]
/// (see license_key_service.dart) to bind an offline license key to the
/// device it was first activated on. Abstracted behind an interface so the
/// binding logic can be unit-tested without a real platform channel.
abstract class DeviceIdProvider {
  Future<String?> getDeviceId();
}

/// Reads `Settings.Secure.ANDROID_ID` via a native platform channel (see
/// MainActivity.kt). That value is scoped per app-signing-key + device +
/// user since Android 8, which is exactly the granularity license binding
/// needs, and it survives a plain uninstall/reinstall of this app.
///
/// Returns null on any failure -- no platform channel implementation (e.g.
/// iOS, which this app's purchase flow doesn't support today either -- see
/// PurchaseService's class doc) or a channel error -- so callers can fail
/// open rather than block a legitimate activation.
class PlatformDeviceIdProvider implements DeviceIdProvider {
  static const _channel = MethodChannel('com.optisec.mobile/device_id');

  @override
  Future<String?> getDeviceId() async {
    try {
      final id = await _channel.invokeMethod<String>('getDeviceId');
      return (id == null || id.isEmpty) ? null : id;
    } catch (_) {
      return null;
    }
  }
}
