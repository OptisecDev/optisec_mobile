import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optisec_mobile/core/services/device_id_provider.dart';
import 'package:optisec_mobile/core/services/license_key_service.dart';

/// Fixed-answer DeviceIdProvider. A null id simulates what
/// PlatformDeviceIdProvider returns when the platform channel fails or
/// isn't implemented (e.g. no Android native side under `flutter test`).
class _FakeDeviceIdProvider implements DeviceIdProvider {
  _FakeDeviceIdProvider(this._id);

  final String? _id;

  @override
  Future<String?> getDeviceId() async => _id;
}

// Same disposable RSA-2048 test keypair and real OPTM-PRO-... keys used in
// license_key_service_test.dart (duplicated here so this file stays
// self-contained) -- signed by a throwaway Python script mirroring
// ~/optisec-licensing/generate_license.py, not the production key.
final _testVerifier = LicenseKeyVerifier(
  modulus: BigInt.parse(
    'af3113c802371ded554a9936a768251cdb6f2f543cba15d1a1e38f747e6a2c2cfb929e5'
    '9bc1ee4c60c5effa19ae6e3d06f63cebe17335713bfbad2d615f82179773623fc6898d0'
    'c7b71c172b79979dc108455ba1b75890f0233945a80e89f8c1be8f015158e830e36c8be'
    'f68099ffd9bf16a949496b340c541bbf12e077cce8dd70f700c328f79a585c0f8907091'
    '191bce78670e2e78be1e935136cec42fe05122a2af2988c03fce1c58501653dd03b53d5'
    'c9b995ff8c138952133cd70fe5ee0148fe5c58bf10c8b883e42c46a77030234274956d4'
    'ad8fed48974915623d1e637b91b33d81f77a01f032b2b9eddeea54d99befb8e63d18180'
    'f43229dc31d9833',
    radix: 16,
  ),
  exponent: BigInt.parse('10001', radix: 16),
);

const _lifetimeKey =
    'OPTM-PRO-eyJsaWNlbnNlZSI6ImxpZmV0aW1lQHRlc3QuY29tIiwiaXNzdWVkQXQiOiIyMDI2'
    'LTA3LTEyVDAzOjI3OjQ5Ljc4OTQ0OCswMDowMCIsImV4cGlyZXNBdCI6bnVsbH0=.jWJKed8S'
    'SkY2lT5lleuNsCNua6Wx6bxmvrP6UyVSo0674bJVfuYCZ-yVyo4jnwUKcKVKkW2PDUAnsRx3V'
    '_QMWfhR-Mu062rIpPiWR1rb646q3qvFeOkD_QCS_8p4Ke6TWOvFUZOhlasVfG-wph_cSwSTrh'
    'tVh7pv8NG8OFzakf9OKKp4vicCU8LoGSlVhffzgr36G1pqLNcfs20ebqVchF8V789AKMw3wGJ'
    'T0dUljkpm3KhaaZ72fp4DoVfixIUnZVjEK0N_TUc_ozRWvu6bIvcQzrOE_VKZuKK5BwJE3E9w'
    '8uSFB9X6ECW8onvKfolMCIDJEWiyaypNPD76q-IBHg==';

const _futureExpiryKey =
    'OPTM-PRO-eyJsaWNlbnNlZSI6ImZ1dHVyZUB0ZXN0LmNvbSIsImlzc3VlZEF0IjoiMjAyNi0w'
    'Ny0xMlQwMzoyNzo0OS43ODk0NDgrMDA6MDAiLCJleHBpcmVzQXQiOiIyMDI3LTA3LTEyVDAzO'
    'jI3OjQ5Ljc4OTQ0OCswMDowMCJ9.mCQugH1W-zfY4aOfj68YdO_mFqTM_uQOhNOuY6bj8CZRe'
    'rt4dnE6-MAagLF9v6Mbu3FEQTItH5aVwZV_SMGEUhNe0b4CpvTpVSqj9QuSA8Xj6u-kmL71RI'
    'pqXyrt4LjXLikogvXEACFubVNHNWMF2LxqLnTaiJYz3ujKGHj6oidibkhuSchx2bKR3n0Xucd'
    'px7r-4AUbFkdCOMYIZnywoJhuEM1ZJfAVHSySoNK_UBo1K_7ixam8plLkAE8xiGibFVSy2i6c'
    '5FYBKsly6EXsU_joA77jTio-FAUV8LTlTTurN8jLshEgIp8g3QE45Ai72zbNg0Dh7UoUX5X84'
    '7S3jQ==';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempDir =
      Directory.systemTemp.createTempSync('license_device_binding_test');
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') return tempDir.path;
    return null;
  });

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() async {
    await GetStorage().erase();
  });

  group('LicenseDeviceBinding', () {
    test('binds the device on first activation', () async {
      final binding = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );

      expect(await binding.checkAndBind(_lifetimeKey), isTrue);
    });

    test('passes when the same device re-verifies the bound key', () async {
      final binding = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );

      expect(await binding.checkAndBind(_lifetimeKey), isTrue);
      expect(await binding.checkAndBind(_lifetimeKey), isTrue);
    });

    test('fails when a different device tries to use an already-bound key',
        () async {
      final onDeviceA = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );
      final onDeviceB = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-B'),
      );

      expect(await onDeviceA.checkAndBind(_lifetimeKey), isTrue);
      expect(await onDeviceB.checkAndBind(_lifetimeKey), isFalse);
    });

    test('rebinds fresh when a different key is activated on the device',
        () async {
      final binding = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );

      expect(await binding.checkAndBind(_lifetimeKey), isTrue);
      // A renewal / different license key on the same device isn't a
      // conflict -- it just replaces the binding.
      expect(await binding.checkAndBind(_futureExpiryKey), isTrue);
    });

    test('fails open when the device id is unavailable', () async {
      final onDeviceA = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );
      final onUnknownDevice = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider(null),
      );

      expect(await onDeviceA.checkAndBind(_lifetimeKey), isTrue);
      expect(await onUnknownDevice.checkAndBind(_lifetimeKey), isTrue);
    });
  });

  group('LicenseKeyService.activate device binding', () {
    // activate()'s success branch calls through to
    // PurchaseService.instance.applyExternalEntitlement(), which lazily
    // constructs the real in_app_purchase plugin and fires an unawaited
    // platform-channel call that flutter test can't safely exercise --
    // subscription_controller_test.dart hits the same limitation and works
    // around it by only exercising activate()'s failure branches. The
    // first-activation-binds / matching-device-passes behavior is already
    // covered directly against LicenseDeviceBinding above; here we only
    // need the rejection branch, which returns before ever touching
    // PurchaseService.
    test(
        'a device with an existing binding to a different device is '
        'rejected with a clear deviceMismatch error', () async {
      final bindingOnDeviceA = LicenseDeviceBinding(
        deviceIdProvider: _FakeDeviceIdProvider('device-A'),
      );
      expect(await bindingOnDeviceA.checkAndBind(_lifetimeKey), isTrue);

      final serviceOnDeviceB = LicenseKeyService.forTesting(
        verifier: _testVerifier,
        deviceBinding: LicenseDeviceBinding(
          deviceIdProvider: _FakeDeviceIdProvider('device-B'),
        ),
      );
      final result = await serviceOnDeviceB.activate(_lifetimeKey);

      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.deviceMismatch);
      // The parsed license is still surfaced, same as the `expired` case,
      // so the UI could show which license this was if it wanted to.
      expect(result.license, isNotNull);
      expect(result.license!.licensee, 'lifetime@test.com');
    });
  });
}
