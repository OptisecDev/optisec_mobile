import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/services/app_lock_service.dart';

/// AppLockService is a thin MethodChannel wrapper: the actual PIN hashing
/// (PBKDF2WithHmacSHA256, constant-time comparison) and lockout/backoff
/// bookkeeping live natively in AppLockStore/PinHasher.kt and are not
/// reachable from Dart, so they aren't covered here -- see the App Lock
/// coverage notes in the task summary. What *is* Dart-side and covered by
/// this file is how the service maps channel results/errors (including the
/// LOCKED_OUT duration payload) into the Dart-facing result types.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mirrors the private `_channel` inside AppLockService. Mocking is keyed
  // by channel name in the test binary messenger, so this reaches the same
  // wire the service talks to without needing a real native side.
  const channel = MethodChannel('com.optisec.mobile/app_lock');
  final service = AppLockService.instance;

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

  group('getInstalledApps', () {
    test('sends the correct method name and no args', () async {
      stubHandler((call) async => <Map<String, dynamic>>[]);

      await service.getInstalledApps();

      expect(lastCall!.method, 'getInstalledApps');
      expect(lastCall!.arguments, isNull);
    });

    test('maps each native map entry to an InstalledAppInfo', () async {
      stubHandler(
        (call) async => [
          {'packageName': 'com.example.one', 'appName': 'One', 'icon': null},
          {'packageName': 'com.example.two', 'appName': 'Two', 'icon': null},
        ],
      );

      final apps = await service.getInstalledApps();

      expect(apps, hasLength(2));
      expect(apps[0].packageName, 'com.example.one');
      expect(apps[1].appName, 'Two');
    });

    test('returns an empty list when native returns null', () async {
      stubHandler((call) async => null);

      expect(await service.getInstalledApps(), isEmpty);
    });

    test('returns an empty list on MissingPluginException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      expect(await service.getInstalledApps(), isEmpty);
    });

    test('returns an empty list on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.getInstalledApps(), isEmpty);
    });
  });

  group('getLockedApps / setLockedApps', () {
    test('getLockedApps sends the correct method name and no args', () async {
      stubHandler((call) async => <String>['a', 'b']);

      final result = await service.getLockedApps();

      expect(lastCall!.method, 'getLockedApps');
      expect(lastCall!.arguments, isNull);
      expect(result, {'a', 'b'});
    });

    test('getLockedApps returns an empty set when native returns null',
        () async {
      stubHandler((call) async => null);

      expect(await service.getLockedApps(), isEmpty);
    });

    test('getLockedApps returns an empty set on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.getLockedApps(), isEmpty);
    });

    test('setLockedApps sends the package set as a list', () async {
      stubHandler((call) async => null);

      await service.setLockedApps({'com.example.one', 'com.example.two'});

      expect(lastCall!.method, 'setLockedApps');
      expect(
        (lastCall!.arguments as List).cast<String>().toSet(),
        {'com.example.one', 'com.example.two'},
      );
    });

    test('setLockedApps swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.setLockedApps({'a'}), completes);
    });
  });

  group('isPinSet', () {
    test('sends the correct method name and no args', () async {
      stubHandler((call) async => true);

      final result = await service.isPinSet();

      expect(lastCall!.method, 'isPinSet');
      expect(lastCall!.arguments, isNull);
      expect(result, isTrue);
    });

    test('defaults to false when native returns null', () async {
      stubHandler((call) async => null);

      expect(await service.isPinSet(), isFalse);
    });

    test('defaults to false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.isPinSet(), isFalse);
    });
  });

  group('setPin', () {
    test('sends the pin argument and returns true on success', () async {
      stubHandler((call) async => null);

      final result = await service.setPin('1234');

      expect(lastCall!.method, 'setPin');
      expect(lastCall!.arguments, {'pin': '1234'});
      expect(result, isTrue);
    });

    test('returns false when the channel throws', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'INVALID_PIN'),
      );

      expect(await service.setPin(''), isFalse);
    });
  });

  group('verifyPin', () {
    test('sends the pin argument', () async {
      stubHandler((call) async => true);

      await service.verifyPin('1234');

      expect(lastCall!.method, 'verifyPin');
      expect(lastCall!.arguments, {'pin': '1234'});
    });

    test('maps a true result to success', () async {
      stubHandler((call) async => true);

      final result = await service.verifyPin('1234');

      expect(result.status, PinVerifyStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.lockoutRemaining, isNull);
    });

    test('maps a false result to incorrect (wrong PIN rejected)', () async {
      stubHandler((call) async => false);

      final result = await service.verifyPin('0000');

      expect(result.status, PinVerifyStatus.incorrect);
      expect(result.isSuccess, isFalse);
    });

    test('maps a LOCKED_OUT PlatformException to lockedOut with remaining duration',
        () async {
      stubHandler(
        (call) async => throw PlatformException(
          code: 'LOCKED_OUT',
          details: 30000,
        ),
      );

      final result = await service.verifyPin('0000');

      expect(result.status, PinVerifyStatus.lockedOut);
      expect(result.lockoutRemaining, const Duration(milliseconds: 30000));
    });

    test('maps a LOCKED_OUT PlatformException with non-int details to zero duration',
        () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'LOCKED_OUT', details: 'oops'),
      );

      final result = await service.verifyPin('0000');

      expect(result.status, PinVerifyStatus.lockedOut);
      expect(result.lockoutRemaining, Duration.zero);
    });

    test('maps any other PlatformException to incorrect', () async {
      stubHandler(
        (call) async => throw PlatformException(code: 'INVALID_PIN'),
      );

      final result = await service.verifyPin('');

      expect(result.status, PinVerifyStatus.incorrect);
    });

    test('maps a non-PlatformException error to incorrect', () async {
      stubHandler((call) async => throw StateError('boom'));

      final result = await service.verifyPin('0000');

      expect(result.status, PinVerifyStatus.incorrect);
    });
  });

  group('overlay permission', () {
    test('hasOverlayPermission sends the correct method name', () async {
      stubHandler((call) async => true);

      final result = await service.hasOverlayPermission();

      expect(lastCall!.method, 'hasOverlayPermission');
      expect(result, isTrue);
    });

    test('hasOverlayPermission defaults to false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.hasOverlayPermission(), isFalse);
    });

    test('openOverlaySettings sends the correct method name with no args',
        () async {
      stubHandler((call) async => null);

      await service.openOverlaySettings();

      expect(lastCall!.method, 'openOverlaySettings');
      expect(lastCall!.arguments, isNull);
    });

    test('openOverlaySettings swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.openOverlaySettings(), completes);
    });
  });

  group('monitor service', () {
    test('isMonitorServiceRunning sends the correct method name', () async {
      stubHandler((call) async => true);

      final result = await service.isMonitorServiceRunning();

      expect(lastCall!.method, 'isMonitorServiceRunning');
      expect(result, isTrue);
    });

    test('isMonitorServiceRunning defaults to false on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.isMonitorServiceRunning(), isFalse);
    });

    test('startMonitorService sends the correct method name with no args',
        () async {
      stubHandler((call) async => null);

      await service.startMonitorService();

      expect(lastCall!.method, 'startMonitorService');
      expect(lastCall!.arguments, isNull);
    });

    test('startMonitorService swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.startMonitorService(), completes);
    });

    test('stopMonitorService sends the correct method name with no args',
        () async {
      stubHandler((call) async => null);

      await service.stopMonitorService();

      expect(lastCall!.method, 'stopMonitorService');
      expect(lastCall!.arguments, isNull);
    });

    test('stopMonitorService swallows errors without throwing', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(service.stopMonitorService(), completes);
    });
  });

  group('battery optimization', () {
    test('isIgnoringBatteryOptimizations sends the correct method name',
        () async {
      stubHandler((call) async => false);

      final result = await service.isIgnoringBatteryOptimizations();

      expect(lastCall!.method, 'isIgnoringBatteryOptimizations');
      expect(result, isFalse);
    });

    test('isIgnoringBatteryOptimizations defaults to true on error', () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      expect(await service.isIgnoringBatteryOptimizations(), isTrue);
    });

    test(
        'requestIgnoreBatteryOptimizations sends the correct method name with no args',
        () async {
      stubHandler((call) async => null);

      await service.requestIgnoreBatteryOptimizations();

      expect(lastCall!.method, 'requestIgnoreBatteryOptimizations');
      expect(lastCall!.arguments, isNull);
    });

    test('requestIgnoreBatteryOptimizations swallows errors without throwing',
        () async {
      stubHandler((call) async => throw PlatformException(code: 'ERR'));

      await expectLater(
        service.requestIgnoreBatteryOptimizations(),
        completes,
      );
    });
  });
}
