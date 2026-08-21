import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/core/services/license_key_service.dart';

// Disposable RSA-2048 test keypair (not the production key) and real
// OPTM-PRO-... strings signed by it via a throwaway Python script mirroring
// ~/optisec-licensing/generate_license.py -- this exercises the actual
// Python(cryptography)-sign / Dart(pointycastle)-verify interop, not just a
// Dart-only round trip.
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

const _expiredKey =
    'OPTM-PRO-eyJsaWNlbnNlZSI6ImV4cGlyZWRAdGVzdC5jb20iLCJpc3N1ZWRBdCI6IjIwMjY'
    'tMDctMTJUMDM6Mjc6NDkuNzg5NDQ4KzAwOjAwIiwiZXhwaXJlc0F0IjoiMjAyNi0wNi0xMlQw'
    'MzoyNzo0OS43ODk0NDgrMDA6MDAifQ==.KdZ4201bbhPjhSia138nAFEef9Pa4Yxpj_60cfk'
    'Qbs_5HDQwCSYBHWh72KZRC7ofxuaRjpX0PAqrwnFqfp7rlotzPiu5DJHJM4VNmXEONcipg2n'
    'zSmCRN_7fEbpu62P_kmPqvl8-qoO6VacOZC4X0JirXiZHd9q6JHBXs1LzlB5uEdGsWVUveZE'
    'XYZzXt4ssaGlm4zIfpLWJ_UiBC_UEDfTIAD9W1SdcoQPK37upbpOFedkMCe3IBX5N9ATa3cW'
    'vt3HY_M2vSJfb6RQxzDFRHDjrtgoSy4MwhbkQEE0HkCyTzBSp54hO3UKzoh95rCg6Ml9_oXL'
    '6TkrpTys0Cn9HVw==';

const _malformedPayloadKey =
    'OPTM-PRO-eyJmb28iOiJiYXIifQ==.XQq8sDVFbdrTL1-5sjno5H0tQffchcK0XOkaIIeWID'
    'hdb3-4f-EVT14m1CgkOEvWgZt0pkwpn3YjtzK5L22S5LtHBdDOGzk3su5RZ3cEAp773uKwDu'
    '2yjwIjrTCu4s2k9X-GlivaRGlpuY08VUCmc5eTqtaPwaQO5yf_x0XgyHD2V3WTFkcjr69KWf'
    'nL1oYsMc5e3L5FGRfzdtZ62Lmao-glU9wIB9SIADpLeY8fyGf3H3ki97IG26CCf2dGiVPyWn'
    'GSaHvB-NRrm8ZdCJWtQlPdwDbB2W8rvgbQbEUeMVKQQtRPHHourQRSFad7-8Q49bvoxjDmE8'
    'd0LEOCFnTDCg==';

void main() {
  group('LicenseKeyVerifier', () {
    test('accepts a valid lifetime key', () {
      final result = _testVerifier.verify(_lifetimeKey);
      expect(result.isValid, isTrue);
      expect(result.license!.licensee, 'lifetime@test.com');
      expect(result.license!.expiresAt, isNull);
    });

    test('accepts a valid key with future expiry', () {
      final result = _testVerifier.verify(_futureExpiryKey);
      expect(result.isValid, isTrue);
      expect(result.license!.licensee, 'future@test.com');
      expect(result.license!.expiresAt, isNotNull);
      expect(result.license!.expiresAt!.isAfter(DateTime.now()), isTrue);
    });

    test('rejects an expired key but still returns the parsed license', () {
      final result = _testVerifier.verify(_expiredKey);
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.expired);
      expect(result.license, isNotNull);
      expect(result.license!.licensee, 'expired@test.com');
    });

    test('rejects a tampered payload', () {
      // Flip one character in the payload segment -- still valid base64,
      // but the signature no longer matches.
      final tampered = _lifetimeKey.replaceFirst('eyJsaWNlbnNlZSI6', 'eyJsaWNlbnNlZSI7');
      final result = _testVerifier.verify(tampered);
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.invalidSignature);
    });

    test('rejects a tampered signature', () {
      final dotIndex = _lifetimeKey.indexOf('.');
      final signaturePart = _lifetimeKey.substring(dotIndex + 1);
      final flipped = signaturePart[0] == 'A' ? 'B' : 'A';
      final tampered =
          '${_lifetimeKey.substring(0, dotIndex + 1)}$flipped${signaturePart.substring(1)}';
      final result = _testVerifier.verify(tampered);
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.invalidSignature);
    });

    test('rejects a garbage string', () {
      final result = _testVerifier.verify('not-a-license-key-at-all');
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.invalidFormat);
    });

    test('rejects a wrong-prefix string', () {
      final result = _testVerifier.verify('OPS4-PRO-abc.def');
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.invalidFormat);
    });

    test('rejects malformed base64', () {
      final result = _testVerifier.verify('OPTM-PRO-not!!valid.also!!not');
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.invalidFormat);
    });

    test('rejects a validly-signed but malformed payload', () {
      final result = _testVerifier.verify(_malformedPayloadKey);
      expect(result.isValid, isFalse);
      expect(result.error, LicenseKeyError.malformedPayload);
    });
  });
}
