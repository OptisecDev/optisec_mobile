import 'package:flutter/services.dart';

import '../../shared/models/vault_entry_model.dart';

enum MasterPasswordVerifyStatus { success, incorrect, lockedOut }

/// Result of [PasswordVaultService.unlockWithMasterPassword]. Mirrors
/// AppLock's `PinVerifyResult` shape so lockout UI stays consistent across
/// both features.
class MasterPasswordVerifyResult {
  final MasterPasswordVerifyStatus status;
  final Duration? lockoutRemaining;

  const MasterPasswordVerifyResult.success()
      : status = MasterPasswordVerifyStatus.success,
        lockoutRemaining = null;

  const MasterPasswordVerifyResult.incorrect()
      : status = MasterPasswordVerifyStatus.incorrect,
        lockoutRemaining = null;

  const MasterPasswordVerifyResult.lockedOut(this.lockoutRemaining)
      : status = MasterPasswordVerifyStatus.lockedOut;

  bool get isSuccess => status == MasterPasswordVerifyStatus.success;
}

enum BiometricUnlockStatus {
  success,
  failed,
  notEnabled,
  keyInvalidated,
  lockedOut,
}

class BiometricUnlockResult {
  final BiometricUnlockStatus status;
  final Duration? lockoutRemaining;

  const BiometricUnlockResult(this.status, {this.lockoutRemaining});

  bool get isSuccess => status == BiometricUnlockStatus.success;
}

enum VaultExportStatus {
  success,
  weakExportPassword,
  reauthFailed,
  cancelled,
  failed,
}

class VaultExportResult {
  final VaultExportStatus status;
  final int entryCount;

  const VaultExportResult(this.status, {this.entryCount = 0});
}

enum VaultImportStatus {
  success,
  badExportPassword,
  invalidFile,
  cancelled,
  notUnlocked,
  failed,
}

class VaultImportResult {
  final VaultImportStatus status;
  final int importedCount;

  const VaultImportResult(this.status, {this.importedCount = 0});
}

/// MethodChannel wrapper over the native Password Vault stack
/// (VaultStore/VaultCryptoManager/VaultBiometricManager/VaultExportImportManager).
/// Only available on Android; every method degrades to a safe default
/// (false/empty/no-op) on other platforms via [MissingPluginException],
/// mirroring [AppLockService]'s conventions.
class PasswordVaultService {
  PasswordVaultService._();

  static final PasswordVaultService instance = PasswordVaultService._();

  static const _channel = MethodChannel('com.optisec.mobile/password_vault');

  Future<bool> isVaultInitialized() async {
    try {
      return await _channel.invokeMethod<bool>('isVaultInitialized') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isUnlocked() async {
    try {
      return await _channel.invokeMethod<bool>('isUnlocked') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setupVault(String masterPassword) async {
    try {
      await _channel
          .invokeMethod('setupVault', {'masterPassword': masterPassword});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<MasterPasswordVerifyResult> unlockWithMasterPassword(
    String masterPassword,
  ) async {
    try {
      final success = await _channel.invokeMethod<bool>(
        'unlockWithMasterPassword',
        {'masterPassword': masterPassword},
      );
      return success == true
          ? const MasterPasswordVerifyResult.success()
          : const MasterPasswordVerifyResult.incorrect();
    } on PlatformException catch (e) {
      if (e.code == 'LOCKED_OUT') {
        final remainingMs = e.details is int ? e.details as int : 0;
        return MasterPasswordVerifyResult.lockedOut(
          Duration(milliseconds: remainingMs),
        );
      }
      return const MasterPasswordVerifyResult.incorrect();
    } catch (_) {
      return const MasterPasswordVerifyResult.incorrect();
    }
  }

  Future<void> lockVault() async {
    try {
      await _channel.invokeMethod('lockVault');
    } catch (_) {
      // Best-effort; session is cleared natively even if this throws.
    }
  }

  Future<bool> canUseBiometric() async {
    try {
      return await _channel.invokeMethod<bool>('canUseBiometric') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isBiometricEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enrollBiometric() async {
    try {
      return await _channel.invokeMethod<bool>('enrollBiometric') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<BiometricUnlockResult> unlockWithBiometric() async {
    try {
      final success =
          await _channel.invokeMethod<bool>('unlockWithBiometric');
      return BiometricUnlockResult(
        success == true
            ? BiometricUnlockStatus.success
            : BiometricUnlockStatus.failed,
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'LOCKED_OUT':
          final remainingMs = e.details is int ? e.details as int : 0;
          return BiometricUnlockResult(
            BiometricUnlockStatus.lockedOut,
            lockoutRemaining: Duration(milliseconds: remainingMs),
          );
        case 'BIOMETRIC_NOT_ENABLED':
          return const BiometricUnlockResult(BiometricUnlockStatus.notEnabled);
        case 'BIOMETRIC_KEY_INVALIDATED':
          return const BiometricUnlockResult(
            BiometricUnlockStatus.keyInvalidated,
          );
        default:
          return const BiometricUnlockResult(BiometricUnlockStatus.failed);
      }
    } catch (_) {
      return const BiometricUnlockResult(BiometricUnlockStatus.failed);
    }
  }

  Future<void> disableBiometric() async {
    try {
      await _channel.invokeMethod('disableBiometric');
    } catch (_) {
      // Best-effort.
    }
  }

  Future<Duration> getAutoLockTimeout() async {
    try {
      final millis =
          await _channel.invokeMethod<int>('getAutoLockTimeoutMillis');
      return Duration(milliseconds: millis ?? 60000);
    } catch (_) {
      return const Duration(minutes: 1);
    }
  }

  Future<void> setAutoLockTimeout(Duration timeout) async {
    try {
      await _channel.invokeMethod(
        'setAutoLockTimeoutMillis',
        {'millis': timeout.inMilliseconds},
      );
    } catch (_) {
      // Best-effort.
    }
  }

  Future<List<VaultEntryModel>> listEntries() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('listEntries');
      if (result == null) return const [];
      return result
          .map((e) =>
              VaultEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<int> entryCount() async {
    try {
      return await _channel.invokeMethod<int>('entryCount') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String?> getEntryPassword(String id) async {
    try {
      return await _channel
          .invokeMethod<String>('getEntryPassword', {'id': id});
    } catch (_) {
      return null;
    }
  }

  Future<String?> upsertEntry({
    String? id,
    required String title,
    required String username,
    required String url,
    required String notes,
    required String password,
  }) async {
    try {
      return await _channel.invokeMethod<String>('upsertEntry', {
        'id': id,
        'title': title,
        'username': username,
        'url': url,
        'notes': notes,
        'password': password,
      });
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      await _channel.invokeMethod('deleteEntry', {'id': id});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<VaultExportResult> exportVault({
    required String masterPassword,
    required String exportPassword,
  }) async {
    try {
      final count = await _channel.invokeMethod<int>('exportVault', {
        'masterPassword': masterPassword,
        'exportPassword': exportPassword,
      });
      return VaultExportResult(VaultExportStatus.success,
          entryCount: count ?? 0);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'WEAK_EXPORT_PASSWORD':
          return const VaultExportResult(
              VaultExportStatus.weakExportPassword);
        case 'REAUTH_FAILED':
          return const VaultExportResult(VaultExportStatus.reauthFailed);
        case 'EXPORT_CANCELLED':
          return const VaultExportResult(VaultExportStatus.cancelled);
        default:
          return const VaultExportResult(VaultExportStatus.failed);
      }
    } catch (_) {
      return const VaultExportResult(VaultExportStatus.failed);
    }
  }

  Future<VaultImportResult> importVault({
    required String exportPassword,
    required bool merge,
  }) async {
    try {
      final count = await _channel.invokeMethod<int>('importVault', {
        'exportPassword': exportPassword,
        'merge': merge,
      });
      return VaultImportResult(VaultImportStatus.success,
          importedCount: count ?? 0);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'BAD_EXPORT_PASSWORD':
          return const VaultImportResult(VaultImportStatus.badExportPassword);
        case 'INVALID_FILE':
          return const VaultImportResult(VaultImportStatus.invalidFile);
        case 'IMPORT_CANCELLED':
          return const VaultImportResult(VaultImportStatus.cancelled);
        case 'NOT_UNLOCKED':
          return const VaultImportResult(VaultImportStatus.notUnlocked);
        default:
          return const VaultImportResult(VaultImportStatus.failed);
      }
    } catch (_) {
      return const VaultImportResult(VaultImportStatus.failed);
    }
  }
}
