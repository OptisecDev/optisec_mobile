import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../../shared/models/subscription_model.dart';
import '../constants/license_public_key.dart';
import 'purchase_service.dart';

/// PKCS1v15/SHA-256 DigestInfo OID, as required by [RSASigner]. Matches
/// what Python's `cryptography` (`padding.PKCS1v15()` + `hashes.SHA256()`)
/// produces -- see ~/optisec-licensing/generate_license.py.
const _sha256DigestIdentifierHex = '0609608648016503040201';

const _keyPrefix = 'OPTM-PRO-';

enum LicenseKeyError { invalidFormat, invalidSignature, malformedPayload, expired }

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

/// Singleton wrapper: verifies a key and, on success, publishes the
/// resulting entitlement through PurchaseService's shared notifier/storage
/// so SubscriptionController picks it up like any other entitlement change.
class LicenseKeyService {
  LicenseKeyService._();

  static final LicenseKeyService instance = LicenseKeyService._();

  static final LicenseKeyVerifier _verifier = LicenseKeyVerifier(
    modulus: LicensePublicKey.modulus,
    exponent: LicensePublicKey.exponent,
  );

  LicenseVerification verify(String rawKey) => _verifier.verify(rawKey);

  LicenseVerification activate(String rawKey) {
    final result = _verifier.verify(rawKey);
    if (result.isValid) {
      PurchaseService.instance.applyExternalEntitlement(
        SubscriptionModel.pro(
          expiryDate: result.license!.expiresAt,
          source: EntitlementSource.licenseKey,
          licenseeLabel: result.license!.licensee,
        ),
      );
    }
    return result;
  }
}
