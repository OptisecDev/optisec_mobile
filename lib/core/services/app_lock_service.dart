import 'package:flutter/services.dart';

import '../../shared/models/installed_app_info.dart';

enum PinVerifyStatus { success, incorrect, lockedOut }

/// Result of [AppLockService.verifyPin]. Distinguishes an incorrect PIN
/// (user can retry immediately) from a lockout (retry blocked for
/// [lockoutRemaining]) so the UI can show the right message.
class PinVerifyResult {
  final PinVerifyStatus status;
  final Duration? lockoutRemaining;

  const PinVerifyResult.success()
      : status = PinVerifyStatus.success,
        lockoutRemaining = null;

  const PinVerifyResult.incorrect()
      : status = PinVerifyStatus.incorrect,
        lockoutRemaining = null;

  const PinVerifyResult.lockedOut(this.lockoutRemaining)
      : status = PinVerifyStatus.lockedOut;

  bool get isSuccess => status == PinVerifyStatus.success;
}

/// MethodChannel wrapper over the native App Lock stack (foreground
/// monitor service, overlay, BiometricPrompt + PIN lock screen). Only
/// available on Android; every method degrades to a safe default
/// (false/empty/no-op) on other platforms via [MissingPluginException].
class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const _channel = MethodChannel('com.optisec.mobile/app_lock');

  Future<List<InstalledAppInfo>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );
      if (result == null) return const [];
      return result
          .map((e) => InstalledAppInfo.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on MissingPluginException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<Set<String>> getLockedApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getLockedApps',
      );
      return result?.cast<String>().toSet() ?? <String>{};
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> setLockedApps(Set<String> packages) async {
    try {
      await _channel.invokeMethod('setLockedApps', packages.toList());
    } catch (_) {
      // Nothing actionable client-side if this fails silently.
    }
  }

  Future<bool> isPinSet() async {
    try {
      return await _channel.invokeMethod<bool>('isPinSet') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    try {
      await _channel.invokeMethod('setPin', {'pin': pin});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<PinVerifyResult> verifyPin(String pin) async {
    try {
      final success =
          await _channel.invokeMethod<bool>('verifyPin', {'pin': pin});
      return success == true
          ? const PinVerifyResult.success()
          : const PinVerifyResult.incorrect();
    } on PlatformException catch (e) {
      if (e.code == 'LOCKED_OUT') {
        final remainingMs = e.details is int ? e.details as int : 0;
        return PinVerifyResult.lockedOut(Duration(milliseconds: remainingMs));
      }
      return const PinVerifyResult.incorrect();
    } catch (_) {
      return const PinVerifyResult.incorrect();
    }
  }

  Future<bool> hasOverlayPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasOverlayPermission') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (_) {
      // Nothing we can do if the Settings screen fails to open.
    }
  }

  Future<bool> isMonitorServiceRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isMonitorServiceRunning') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> startMonitorService() async {
    try {
      await _channel.invokeMethod('startMonitorService');
    } catch (_) {
      // Best-effort; the UI re-checks isMonitorServiceRunning on resume.
    }
  }

  Future<void> stopMonitorService() async {
    try {
      await _channel.invokeMethod('stopMonitorService');
    } catch (_) {
      // Best-effort.
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          true;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {
      // Nothing we can do if the Settings screen fails to open.
    }
  }
}
