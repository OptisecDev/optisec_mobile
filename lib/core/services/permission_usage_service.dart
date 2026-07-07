import 'package:flutter/services.dart';

import '../../shared/models/permission_usage_record.dart';

enum PermissionUsageStatus { ok, error }

/// Result of a [PermissionUsageService.getUsageRecords] query. Distinguishes
/// a genuinely empty result ([PermissionUsageStatus.ok] with no records) from
/// a failed query ([PermissionUsageStatus.error]) so the UI can offer a retry
/// instead of silently showing "no activity".
class PermissionUsageResult {
  final PermissionUsageStatus status;
  final List<PermissionUsageRecord> records;
  final String? errorMessage;

  const PermissionUsageResult.ok(this.records)
      : status = PermissionUsageStatus.ok,
        errorMessage = null;

  const PermissionUsageResult.error(this.errorMessage)
      : status = PermissionUsageStatus.error,
        records = const [];
}

/// Reads app-level permission usage (camera/mic/location) via the native
/// UsageStatsManager proxy. Requires the user to grant "Usage Access" in
/// system settings — see [hasUsageAccess] / [openUsageAccessSettings].
/// Only available on Android; always returns empty on other platforms.
class PermissionUsageService {
  PermissionUsageService._();

  static final PermissionUsageService instance = PermissionUsageService._();

  static const _channel =
      MethodChannel('com.optisec.mobile/permission_usage');

  Future<PermissionUsageResult> getUsageRecords() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getPermissionUsage',
      );
      if (result == null) return const PermissionUsageResult.ok([]);
      final records = result
          .map((e) => PermissionUsageRecord.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
      return PermissionUsageResult.ok(records);
    } on MissingPluginException {
      // Non-Android platform (Linux/iOS/desktop) or API < 21 — no native
      // handler registered. Expected, not a query failure to retry.
      return const PermissionUsageResult.ok([]);
    } on PlatformException catch (e) {
      // Usage Access denied, or the native query failed — distinct from an
      // empty result so the UI can offer a retry.
      return PermissionUsageResult.error(e.message ?? e.code);
    } catch (e) {
      // Malformed data from the native side (e.g. fromJson parse failure).
      return PermissionUsageResult.error(e.toString());
    }
  }

  Future<bool> hasUsageAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openUsageAccessSettings() async {
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } catch (_) {
      // Nothing we can do if the Settings screen fails to open.
    }
  }
}
