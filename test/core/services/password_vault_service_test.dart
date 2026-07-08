import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/services/password_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mirrors the private `_channel` inside PasswordVaultService. Mocking is
  // keyed by channel name in the test binary messenger, so this reaches the
  // same wire the service talks to without needing a real native side.
  const channel = MethodChannel('com.optisec.mobile/password_vault');
  final service = PasswordVaultService.instance;

  MethodCall? lastCall;

  void stubHandler(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      lastCall = call;
      return handler(call);
    });
  }

  setUp(() {
    lastCall = null;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('no-argument boolean getters', () {
    test('isVaultInitialized sends the correct method name and no args', () async {
      stubHandler((call) async => true);

      final result = await service.isVaultInitialized();

      expect(lastCall!.method, 'isVaultInitialized');
      expect(lastCall!.arguments, isNull);
      expect(result, isTrue);
    });

    test('isVaultInitialized defaults to false when native returns null', () async {
      stubHandler((call) async => null);

      final result = await service.isVaultInitialized();

      expect(result, isFalse);
    });

    test('isVaultInitialized defaults to false on PlatformException', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      final result = await service.isVaultInitialized();

      expect(result, isFalse);
    });

    test('isUnlocked sends the correct method name and no args', () async {
      stubHandler((call) async => true);

      final result = await service.isUnlocked();

      expect(lastCall!.method, 'isUnlocked');
      expect(lastCall!.arguments, isNull);
      expect(result, isTrue);
    });

    test('isUnlocked defaults to false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.isUnlocked(), isFalse);
    });

    test('canUseBiometric sends the correct method name', () async {
      stubHandler((call) async => true);

      final result = await service.canUseBiometric();

      expect(lastCall!.method, 'canUseBiometric');
      expect(result, isTrue);
    });

    test('isBiometricEnabled sends the correct method name', () async {
      stubHandler((call) async => false);

      final result = await service.isBiometricEnabled();

      expect(lastCall!.method, 'isBiometricEnabled');
      expect(result, isFalse);
    });

    test('enrollBiometric sends the correct method name', () async {
      stubHandler((call) async => true);

      final result = await service.enrollBiometric();

      expect(lastCall!.method, 'enrollBiometric');
      expect(result, isTrue);
    });

    test('enrollBiometric defaults to false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.enrollBiometric(), isFalse);
    });
  });

  group('setupVault', () {
    test('sends masterPassword argument and returns true on success', () async {
      stubHandler((call) async => null);

      final result = await service.setupVault('hunter2');

      expect(lastCall!.method, 'setupVault');
      expect(lastCall!.arguments, {'masterPassword': 'hunter2'});
      expect(result, isTrue);
    });

    test('returns false when the channel throws', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      final result = await service.setupVault('hunter2');

      expect(result, isFalse);
    });
  });

  group('unlockWithMasterPassword', () {
    test('sends masterPassword argument', () async {
      stubHandler((call) async => true);

      await service.unlockWithMasterPassword('hunter2');

      expect(lastCall!.method, 'unlockWithMasterPassword');
      expect(lastCall!.arguments, {'masterPassword': 'hunter2'});
    });

    test('maps a true result to success', () async {
      stubHandler((call) async => true);

      final result = await service.unlockWithMasterPassword('hunter2');

      expect(result.status, MasterPasswordVerifyStatus.success);
      expect(result.isSuccess, isTrue);
    });

    test('maps a false result to incorrect', () async {
      stubHandler((call) async => false);

      final result = await service.unlockWithMasterPassword('wrong');

      expect(result.status, MasterPasswordVerifyStatus.incorrect);
      expect(result.isSuccess, isFalse);
    });

    test('maps a LOCKED_OUT PlatformException to lockedOut with remaining duration', () async {
      stubHandler(
        (call) async => throw PlatformException(
          code: 'LOCKED_OUT',
          details: 30000,
        ),
      );

      final result = await service.unlockWithMasterPassword('wrong');

      expect(result.status, MasterPasswordVerifyStatus.lockedOut);
      expect(result.lockoutRemaining, const Duration(milliseconds: 30000));
    });

    test('maps a LOCKED_OUT PlatformException with non-int details to zero duration', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'LOCKED_OUT', details: 'oops'),
      );

      final result = await service.unlockWithMasterPassword('wrong');

      expect(result.status, MasterPasswordVerifyStatus.lockedOut);
      expect(result.lockoutRemaining, Duration.zero);
    });

    test('maps any other PlatformException to incorrect', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'SOME_OTHER_ERROR'),
      );

      final result = await service.unlockWithMasterPassword('wrong');

      expect(result.status, MasterPasswordVerifyStatus.incorrect);
    });

    test('maps a non-PlatformException error to incorrect', () async {
      stubHandler((call) async => throw StateError('boom'));

      final result = await service.unlockWithMasterPassword('wrong');

      expect(result.status, MasterPasswordVerifyStatus.incorrect);
    });
  });

  group('lockVault / disableBiometric (fire-and-forget)', () {
    test('lockVault sends the correct method name with no args', () async {
      stubHandler((call) async => null);

      await service.lockVault();

      expect(lastCall!.method, 'lockVault');
      expect(lastCall!.arguments, isNull);
    });

    test('lockVault swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.lockVault(), completes);
    });

    test('disableBiometric sends the correct method name with no args', () async {
      stubHandler((call) async => null);

      await service.disableBiometric();

      expect(lastCall!.method, 'disableBiometric');
      expect(lastCall!.arguments, isNull);
    });

    test('disableBiometric swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.disableBiometric(), completes);
    });
  });

  group('unlockWithBiometric', () {
    test('sends the correct method name with no args', () async {
      stubHandler((call) async => true);

      await service.unlockWithBiometric();

      expect(lastCall!.method, 'unlockWithBiometric');
      expect(lastCall!.arguments, isNull);
    });

    test('maps a true result to success', () async {
      stubHandler((call) async => true);

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.success);
    });

    test('maps a false result to failed', () async {
      stubHandler((call) async => false);

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.failed);
    });

    test('maps LOCKED_OUT to lockedOut with remaining duration', () async {
      stubHandler(
        (call) async => throw PlatformException(
          code: 'LOCKED_OUT',
          details: 15000,
        ),
      );

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.lockedOut);
      expect(result.lockoutRemaining, const Duration(milliseconds: 15000));
    });

    test('maps BIOMETRIC_NOT_ENABLED to notEnabled', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'BIOMETRIC_NOT_ENABLED'),
      );

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.notEnabled);
    });

    test('maps BIOMETRIC_KEY_INVALIDATED to keyInvalidated', () async {
      stubHandler(
        (call) async =>
            throw PlatformException(code: 'BIOMETRIC_KEY_INVALIDATED'),
      );

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.keyInvalidated);
    });

    test('maps an unrecognized error code to failed', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'SOMETHING_ELSE'),
      );

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.failed);
    });

    test('maps a non-PlatformException error to failed', () async {
      stubHandler((call) async => throw StateError('boom'));

      final result = await service.unlockWithBiometric();

      expect(result.status, BiometricUnlockStatus.failed);
    });
  });

  group('auto-lock timeout', () {
    test('getAutoLockTimeout sends the correct method name with no args', () async {
      stubHandler((call) async => 120000);

      await service.getAutoLockTimeout();

      expect(lastCall!.method, 'getAutoLockTimeoutMillis');
      expect(lastCall!.arguments, isNull);
    });

    test('getAutoLockTimeout converts millis to a Duration', () async {
      stubHandler((call) async => 120000);

      final result = await service.getAutoLockTimeout();

      expect(result, const Duration(milliseconds: 120000));
    });

    test('getAutoLockTimeout defaults to 60s when native returns null', () async {
      stubHandler((call) async => null);

      final result = await service.getAutoLockTimeout();

      expect(result, const Duration(minutes: 1));
    });

    test('getAutoLockTimeout defaults to 60s on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      final result = await service.getAutoLockTimeout();

      expect(result, const Duration(minutes: 1));
    });

    test('setAutoLockTimeout sends millis argument', () async {
      stubHandler((call) async => null);

      await service.setAutoLockTimeout(const Duration(minutes: 5));

      expect(lastCall!.method, 'setAutoLockTimeoutMillis');
      expect(lastCall!.arguments, {'millis': 300000});
    });

    test('setAutoLockTimeout sends zero millis for Duration.zero (immediate lock)', () async {
      stubHandler((call) async => null);

      await service.setAutoLockTimeout(Duration.zero);

      expect(lastCall!.arguments, {'millis': 0});
    });

    test('setAutoLockTimeout swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(
        service.setAutoLockTimeout(const Duration(minutes: 1)),
        completes,
      );
    });
  });

  group('listEntries', () {
    test('sends the correct method name with no args', () async {
      stubHandler((call) async => <Map<String, dynamic>>[]);

      await service.listEntries();

      expect(lastCall!.method, 'listEntries');
      expect(lastCall!.arguments, isNull);
    });

    test('maps each native map entry to a VaultEntryModel', () async {
      stubHandler(
        (call) async => [
          {
            'id': 'e1',
            'title': 'Entry One',
            'username': 'user1',
            'url': 'https://one.example',
            'notes': 'n1',
            'createdAt': 1000,
            'updatedAt': 2000,
          },
          {
            'id': 'e2',
            'title': 'Entry Two',
            'username': 'user2',
            'url': 'https://two.example',
            'notes': 'n2',
            'createdAt': 3000,
            'updatedAt': 4000,
          },
        ],
      );

      final entries = await service.listEntries();

      expect(entries, hasLength(2));
      expect(entries[0].id, 'e1');
      expect(entries[1].id, 'e2');
    });

    test('returns an empty list when native returns null', () async {
      stubHandler((call) async => null);

      final entries = await service.listEntries();

      expect(entries, isEmpty);
    });

    test('returns an empty list on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      final entries = await service.listEntries();

      expect(entries, isEmpty);
    });
  });

  group('entryCount', () {
    test('sends the correct method name with no args', () async {
      stubHandler((call) async => 7);

      final result = await service.entryCount();

      expect(lastCall!.method, 'entryCount');
      expect(lastCall!.arguments, isNull);
      expect(result, 7);
    });

    test('defaults to 0 when native returns null', () async {
      stubHandler((call) async => null);

      expect(await service.entryCount(), 0);
    });

    test('defaults to 0 on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.entryCount(), 0);
    });
  });

  group('getEntryPassword', () {
    test('sends the id argument', () async {
      stubHandler((call) async => 'the-password');

      final result = await service.getEntryPassword('entry-1');

      expect(lastCall!.method, 'getEntryPassword');
      expect(lastCall!.arguments, {'id': 'entry-1'});
      expect(result, 'the-password');
    });

    test('returns null on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.getEntryPassword('entry-1'), isNull);
    });
  });

  group('upsertEntry', () {
    test('sends all fields including password for a new entry (id null)', () async {
      stubHandler((call) async => 'new-id');

      final result = await service.upsertEntry(
        title: 'Title',
        username: 'user',
        url: 'https://example.com',
        notes: 'notes',
        password: 'pw123',
      );

      expect(lastCall!.method, 'upsertEntry');
      expect(lastCall!.arguments, {
        'id': null,
        'title': 'Title',
        'username': 'user',
        'url': 'https://example.com',
        'notes': 'notes',
        'password': 'pw123',
      });
      expect(result, 'new-id');
    });

    test('sends the id when updating an existing entry', () async {
      stubHandler((call) async => 'existing-id');

      await service.upsertEntry(
        id: 'existing-id',
        title: 'Title',
        username: 'user',
        url: 'https://example.com',
        notes: 'notes',
        password: 'pw123',
      );

      expect(lastCall!.arguments, containsPair('id', 'existing-id'));
    });

    test('returns null on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      final result = await service.upsertEntry(
        title: 'Title',
        username: 'user',
        url: 'https://example.com',
        notes: 'notes',
        password: 'pw123',
      );

      expect(result, isNull);
    });
  });

  group('deleteEntry', () {
    test('sends the id argument and returns true on success', () async {
      stubHandler((call) async => null);

      final result = await service.deleteEntry('entry-1');

      expect(lastCall!.method, 'deleteEntry');
      expect(lastCall!.arguments, {'id': 'entry-1'});
      expect(result, isTrue);
    });

    test('returns false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.deleteEntry('entry-1'), isFalse);
    });
  });

  group('exportVault', () {
    test('sends masterPassword and exportPassword arguments', () async {
      stubHandler((call) async => 3);

      await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'export',
      );

      expect(lastCall!.method, 'exportVault');
      expect(lastCall!.arguments, {
        'masterPassword': 'master',
        'exportPassword': 'export',
      });
    });

    test('maps a successful count to VaultExportStatus.success', () async {
      stubHandler((call) async => 5);

      final result = await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'export',
      );

      expect(result.status, VaultExportStatus.success);
      expect(result.entryCount, 5);
    });

    test('maps WEAK_EXPORT_PASSWORD to weakExportPassword', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'WEAK_EXPORT_PASSWORD'),
      );

      final result = await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'weak',
      );

      expect(result.status, VaultExportStatus.weakExportPassword);
    });

    test('maps REAUTH_FAILED to reauthFailed', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'REAUTH_FAILED'),
      );

      final result = await service.exportVault(
        masterPassword: 'wrong',
        exportPassword: 'export',
      );

      expect(result.status, VaultExportStatus.reauthFailed);
    });

    test('maps EXPORT_CANCELLED to cancelled', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'EXPORT_CANCELLED'),
      );

      final result = await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'export',
      );

      expect(result.status, VaultExportStatus.cancelled);
    });

    test('maps an unrecognized error code to failed', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'WHATEVER'),
      );

      final result = await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'export',
      );

      expect(result.status, VaultExportStatus.failed);
    });

    test('maps a non-PlatformException error to failed', () async {
      stubHandler((call) async => throw StateError('boom'));

      final result = await service.exportVault(
        masterPassword: 'master',
        exportPassword: 'export',
      );

      expect(result.status, VaultExportStatus.failed);
    });
  });

  group('importVault', () {
    test('sends exportPassword and merge arguments', () async {
      stubHandler((call) async => 2);

      await service.importVault(exportPassword: 'export', merge: true);

      expect(lastCall!.method, 'importVault');
      expect(lastCall!.arguments, {
        'exportPassword': 'export',
        'merge': true,
      });
    });

    test('maps a successful count to VaultImportStatus.success', () async {
      stubHandler((call) async => 4);

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.success);
      expect(result.importedCount, 4);
    });

    test('maps BAD_EXPORT_PASSWORD to badExportPassword', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'BAD_EXPORT_PASSWORD'),
      );

      final result =
          await service.importVault(exportPassword: 'wrong', merge: false);

      expect(result.status, VaultImportStatus.badExportPassword);
    });

    test('maps INVALID_FILE to invalidFile', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'INVALID_FILE'),
      );

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.invalidFile);
    });

    test('maps IMPORT_CANCELLED to cancelled', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'IMPORT_CANCELLED'),
      );

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.cancelled);
    });

    test('maps NOT_UNLOCKED to notUnlocked', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'NOT_UNLOCKED'),
      );

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.notUnlocked);
    });

    test('maps an unrecognized error code to failed', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'WHATEVER'),
      );

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.failed);
    });

    test('maps a non-PlatformException error to failed', () async {
      stubHandler((call) async => throw StateError('boom'));

      final result =
          await service.importVault(exportPassword: 'export', merge: false);

      expect(result.status, VaultImportStatus.failed);
    });
  });
}
