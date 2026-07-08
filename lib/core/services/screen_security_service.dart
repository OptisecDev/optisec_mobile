import 'package:flutter/services.dart';

/// Toggles `FLAG_SECURE` on the native window so vault screens can't be
/// screenshotted, screen-recorded, or shown in the recents-apps thumbnail.
/// Call [enable] when a sensitive screen becomes visible and [disable] when
/// leaving it — it's a global window flag, not per-screen, so callers own
/// pairing the two calls correctly (typically in a controller's `onInit`/
/// `onClose`).
class ScreenSecurityService {
  ScreenSecurityService._();

  static final ScreenSecurityService instance = ScreenSecurityService._();

  static const _channel = MethodChannel('com.optisec.mobile/screen_security');

  Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {
      // Best-effort; not available off Android.
    }
  }

  Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {
      // Best-effort.
    }
  }
}
