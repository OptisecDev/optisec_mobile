import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pointycastle/export.dart';

import '../../shared/models/subscription_model.dart';
import '../constants/license_public_key.dart';
import 'device_id_provider.dart';
import 'purchase_service.dart';

/// PKCS1v15/SHA-256 DigestInfo OID, as required by [RSASigner]. Matches
/// what Python's `cryptography` (`padding.PKCS1v15()` + `hashes.SHA256()`)
/// produces -- see ~/optisec-licensing/generate_license.py.
const _sha256DigestIdentifierHex = '0609608648016503040201';

const _keyPrefix = 'OPTM-PRO-';

enum LicenseKeyError {
  invalidFormat,
  invalidSignature,
  malformedPayload,
  expired,
  deviceMismatch,
}

class ParsedLicense {
  final String licensee;
  final DateTime issuedAt;
  final DateTime? expiresAt;

  const ParsedLicense({
    required this.licensee,
    required this.issuedAt,
    this.expiresAt,
  });
}

class LicenseVerification {
  final bool isValid;
  final LicenseKeyError? error;

  /// Present even when [error] is [LicenseKeyError.expired], so the UI can
  /// show a specific "expired on ..." message rather than a generic one.
  final ParsedLicense? license;

  const LicenseVerification._(this.isValid, this.error, this.license);

  const LicenseVerification.valid(ParsedLicense license)
      : this._(true, null, license);

  const LicenseVerification.invalid(LicenseKeyError error, [ParsedLicense? license])
      : this._(false, error, license);
}

/// Pure RSA-SHA256 license-key verifier. No dependency on PurchaseService
/// or GetStorage, so it's unit-testable in isolation with a throwaway
/// keypair -- see test/core/services/license_key_service_test.dart.
class LicenseKeyVerifier {
  final BigInt modulus;
  final BigInt exponent;

  const LicenseKeyVerifier({required this.modulus, required this.exponent});

  LicenseVerification verify(String rawKey) {
    final key = rawKey.trim();
    if (!key.startsWith(_keyPrefix)) {
      return const LicenseVerification.invalid(LicenseKeyError.invalidFormat);
    }

    final body = key.substring(_keyPrefix.length);
    final dotIndex = body.indexOf('.');
    if (dotIndex == -1) {
      return const LicenseVerification.invalid(LicenseKeyError.invalidFormat);
    }

    final Uint8List payloadBytes;
    final Uint8List signatureBytes;
    try {
      payloadBytes = base64Url.decode(body.substring(0, dotIndex));
      signatureBytes = base64Url.decode(body.substring(dotIndex + 1));
    } on FormatException {
      return const LicenseVerification.invalid(LicenseKeyError.invalidFormat);
    }

    if (!_verifySignature(payloadBytes, signatureBytes)) {
      return const LicenseVerification.invalid(LicenseKeyError.invalidSignature);
    }

    final ParsedLicense license;
    try {
      final json = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      license = ParsedLicense(
        licensee: json['licensee'] as String,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.parse(json['expiresAt'] as String),
      );
    } catch (_) {
      return const LicenseVerification.invalid(LicenseKeyError.malformedPayload);
    }

    if (license.expiresAt != null && license.expiresAt!.isBefore(DateTime.now())) {
      return LicenseVerification.invalid(LicenseKeyError.expired, license);
    }

    return LicenseVerification.valid(license);
  }

  bool _verifySignature(Uint8List payloadBytes, Uint8List signatureBytes) {
    final signer = RSASigner(SHA256Digest(), _sha256DigestIdentifierHex);
    signer.init(
      false,
      PublicKeyParameter<RSAPublicKey>(RSAPublicKey(modulus, exponent)),
    );
    try {
      return signer.verifySignature(payloadBytes, RSASignature(signatureBytes));
    } on ArgumentError {
      // Malformed signature bytes (wrong length etc.) -- treat as invalid,
      // not a crash.
      return false;
    }
  }
}

/// Binds an offline license key to the device it's first activated on, so
/// that a locally-copied/restored entitlement (e.g. an `adb backup`/restore
/// or a cloned app-data folder carrying this app's GetStorage box to a
/// different physical device) can't silently pass as a verified activation
/// on a device it was never actually verified on.
///
/// This app has no license server (see ~/optisec-licensing/README.md), so
/// there is nothing to coordinate binding across devices in real time. What
/// this DOES solve: a license key's local activation record can't be lifted
/// to another device by copying local storage alone. What this does NOT
/// solve: nothing stops the same `OPTM-PRO-...` key text being typed into
/// the "Enter License Key" screen on two separate devices independently --
/// each would see no existing local binding and activate cleanly. Only a
/// real license server, tracking activations centrally, could prevent that;
/// this is the same accepted tradeoff the README already documents for the
/// lack of server-side revocation.
class LicenseDeviceBinding {
  LicenseDeviceBinding({DeviceIdProvider? deviceIdProvider})
      : _deviceIdProvider = deviceIdProvider ?? PlatformDeviceIdProvider();

  static const _storageKey = 'license_key_device_binding';

  final DeviceIdProvider _deviceIdProvider;

  // Lazy rather than a field initializer: constructing LicenseKeyService's
  // default LicenseDeviceBinding must stay side-effect-free for every
  // caller of LicenseKeyService.instance, including ones that only ever
  // hit an invalid-signature/format result and never call checkAndBind --
  // GetStorage() shouldn't be touched (and doesn't need path_provider
  // mocked in tests) until a binding check actually runs.
  GetStorage? _boxInstance;
  GetStorage get _box => _boxInstance ??= GetStorage();

  /// Call only after [rawKey] has already passed signature verification.
  /// Returns `true` if activation should proceed -- first-ever binding, a
  /// different key than whatever was bound before (e.g. a renewal), or the
  /// same key re-verified on the same device -- or `false` if [rawKey] is
  /// already bound to a device other than the one running this call.
  Future<bool> checkAndBind(String rawKey) async {
    final currentDeviceId = await _deviceIdProvider.getDeviceId();
    if (currentDeviceId == null) {
      // No device id available (platform channel failed, or a platform
      // without an implementation) -- fail open rather than blocking a
      // legitimate activation on a missing native implementation.
      return true;
    }

    final keyHash = _hashKey(rawKey);
    final stored = _box.read<Map<String, dynamic>>(_storageKey);

    if (stored == null || stored['licenseKeyHash'] != keyHash) {
      _box.write(_storageKey, {
        'licenseKeyHash': keyHash,
        'deviceId': currentDeviceId,
      });
      return true;
    }

    return stored['deviceId'] == currentDeviceId;
  }

  static String _hashKey(String rawKey) {
    final bytes = Uint8List.fromList(utf8.encode(rawKey));
    final digest = SHA256Digest().process(bytes);
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Singleton wrapper: verifies a key, checks/records its device binding,
/// and on success publishes the resulting entitlement through
/// PurchaseService's shared notifier/storage so SubscriptionController
/// picks it up like any other entitlement change.
class LicenseKeyService {
  LicenseKeyService._({
    LicenseKeyVerifier? verifier,
    LicenseDeviceBinding? deviceBinding,
  })  : _verifier = verifier ??
            LicenseKeyVerifier(
              modulus: LicensePublicKey.modulus,
              exponent: LicensePublicKey.exponent,
            ),
        _deviceBinding = deviceBinding ?? LicenseDeviceBinding();

  static final LicenseKeyService instance = LicenseKeyService._();

  /// Test-only seam: build an instance with an injected verifier/device
  /// binding, so the device-binding branch of [activate] can be exercised
  /// with a disposable test keypair and a fake [DeviceIdProvider] instead
  /// of the real production key and a real platform channel.
  @visibleForTesting
  factory LicenseKeyService.forTesting({
    required LicenseKeyVerifier verifier,
    required LicenseDeviceBinding deviceBinding,
  }) =>
      LicenseKeyService._(verifier: verifier, deviceBinding: deviceBinding);

  final LicenseKeyVerifier _verifier;
  final LicenseDeviceBinding _deviceBinding;

  LicenseVerification verify(String rawKey) => _verifier.verify(rawKey);

  Future<LicenseVerification> activate(String rawKey) async {
    final result = _verifier.verify(rawKey);
    if (!result.isValid) return result;

    if (!await _deviceBinding.checkAndBind(rawKey)) {
      return LicenseVerification.invalid(
        LicenseKeyError.deviceMismatch,
        result.license,
      );
    }

    PurchaseService.instance.applyExternalEntitlement(
      SubscriptionModel.pro(
        expiryDate: result.license!.expiresAt,
        source: EntitlementSource.licenseKey,
        licenseeLabel: result.license!.licensee,
      ),
    );
    return result;
  }
}
