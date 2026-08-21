import 'package:flutter/services.dart';

/// Toggles `FLAG_SECURE` on the native window so vault screens can't be
/// screenshotted, screen-recorded, or shown in the recents-apps thumbnail.
/// Call [enable] when a sensitive screen becomes visible and [disable] when
/// leaving it — several vault controllers do this independently in their
/// `onInit`/`onClose` (e.g. the entry list stays active underneath an entry
/// detail screen also enabling it), so this keeps a reference count and
/// only actually toggles the underlying (global, not per-screen) window
/// flag when the last interested screen goes away.
class ScreenSecurityService {
  ScreenSecurityService._();

  static final ScreenSecurityService instance = ScreenSecurityService._();

  static const _channel = MethodChannel('com.optisec.mobile/screen_security');

  int _refCount = 0;

  Future<void> enable() async {
    _refCount++;
    if (_refCount > 1) return; // already on for another screen
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {
      // Best-effort; not available off Android.
    }
  }

  Future<void> disable() async {
    if (_refCount == 0) return; // unmatched disable; nothing to undo
    _refCount--;
    if (_refCount > 0) return; // still needed by another active screen
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {
      // Best-effort.
    }
  }
}
