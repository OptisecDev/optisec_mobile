/// Public half of the RSA-2048 keypair used to sign OptiSec Mobile offline
/// license keys. Safe to commit -- this can only *verify* signatures, not
/// forge them. The private key is kept outside this repo entirely (see
/// ~/optisec-licensing/README.md on the machine that issues license keys).
///
/// If this key is ever rotated, every previously-issued license key stops
/// verifying, and a new app release carrying the new public key is
/// required -- rotate only if the private key is suspected compromised.
class LicensePublicKey {
  LicensePublicKey._();

  static final BigInt modulus = BigInt.parse(
    'a659adb49794a0f5421965178a835e3de27fda3d6d82a2f20f045a4194e091659550cef'
    '079b5155dd9ac4a5744eb3c56f46c86cd7912137aa0f5aed2a8f73d651a1126d6f3dfd7'
    '07939ec6273e7cf1f686e1a27e4b7ff5f55532cf01120e3f46e2b38d490b4daec315c68'
    '8e4487421f12ff8e35532fd444dfddb930052720d4800740e6a79b83b7566d866a8313'
    'd075b2fcde90c6cc8e515cf9cd39d856e756dc845b87cd8c68c6822d78e5eeae4d1372b'
    '385a4852935f993ac357dbe3112a9fdf1bc975aabe1a3d5420fc32814df444edef96dad'
    '8887f91c56f2edc5c352369657d50d501587ab58069b4a83c2f92ace122e8240465fc4c'
    '9505e4374a21c301',
    radix: 16,
  );

  static final BigInt exponent = BigInt.parse('10001', radix: 16); // 65537
}
