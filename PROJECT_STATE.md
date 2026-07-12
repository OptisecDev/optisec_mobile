# Project State — OptiSec Mobile

## Security audit remediation (2026-07-12)

A prior read-only security audit confirmed the app's core crypto is solid and
required no changes: salt generation, IV generation, PBKDF2 parameters,
Android Keystore usage, and biometric key binding (`VaultCryptoManager.kt`)
were all reviewed and left untouched in this pass. Three real issues were
identified and prioritized; all three have now been remediated and verified.

### Issue 1 — Privacy Guard fabricated per-app permission data (FIXED)

**Was:** `PrivacyGuardController.checkPermissions()` hardcoded fake
`appNames`/`appsCount` values per permission (e.g. `['Google Maps', 'Weather
App', 'Food Delivery']` for location) — not derived from any real device
query.

**Fix:** Added `getPermissionHolders()` to the existing
`com.optisec.mobile/permission_usage` native channel (`MainActivity.kt`),
reusing the same `PackageManager`-based pattern already proven by
`getPermissionUsage()`/`grantedTrackedPermissions()`. It enumerates
launcher-visible apps (via the manifest's existing `<queries>` intent-filter,
already used by App Lock's app picker) and checks each one's granted
permissions for all 6 Privacy Guard categories: location, camera, microphone,
contacts, phone, storage (including Android 13+ `READ_MEDIA_*`). No new
manifest permission was needed, and no Usage Access grant is required for
this (unlike the usage-timeline feature). `PermissionUsageService.dart` and
`PrivacyGuardController.checkPermissions()` were updated to consume this real
data; on any query failure the UI falls back to an empty list (0 apps),
never fabricated names.

**Known, disclosed scope limit (not a bug):** only sees apps with a launcher
icon — background-only apps without one won't appear. Same limitation the
App Lock app picker already accepts elsewhere in the app.

**Files:** `MainActivity.kt`, `core/services/permission_usage_service.dart`,
`features/privacy_guard/controllers/privacy_guard_controller.dart`.

### Issue 2 — In-app purchase entitlement is client-side only (HARDENED, NOT FULLY SOLVED)

**Was:** `PurchaseService._grantEntitlement()` trusted `purchase.status`
(`purchased`/`restored`) alone, with zero read of `purchase.verificationData`
— no cryptographic check of any kind.

**Fix:** Added local RSA/SHA1 signature verification against the app's Play
Console license public key, using `java.security` (built into Android — no
new Gradle dependency):
- New `PurchaseChannelHandler.kt` (`com.optisec.mobile/purchase_verification`
  channel) verifies a purchase's signature against a `BASE64_PUBLIC_KEY`
  constant.
- `PurchaseService.dart` casts to `GooglePlayPurchaseDetails`, extracts
  `originalJson`/`signature` from `billingClientPurchase`, and calls the
  native check before granting entitlement.
- `in_app_purchase_android` (already resolved transitively) was promoted to
  a direct `pubspec.yaml` dependency since the code now imports
  `GooglePlayPurchaseDetails` directly — confirmed via `flutter pub get`
  that no new package entered the dependency tree.

**⚠️ ACCEPTED LIMITATION — do not mistake this for "fully solved" in a
future session:** `BASE64_PUBLIC_KEY` in `PurchaseChannelHandler.kt` is
currently **blank** (a `TODO` marks the spot) — the user chose to add their
real Play Console key themselves rather than paste it into this session.
Until that key is filled in, `verify()` always returns `null`, which the
Dart side treats as "verification unavailable" and falls back to the
pre-existing status-only trust (i.e. **no enforcement is active yet**).
Even once the key is added, this remains **client-side hardening only** — a
rooted/instrumented device can still patch around a local check. True
tamper-resistance requires a backend that re-verifies the purchase token
against the Play Developer API; this app has no backend today. This is a
known, explicitly accepted gap, not something this pass claims to close.

**Files:** `android/.../purchase/PurchaseChannelHandler.kt` (new),
`MainActivity.kt`, `core/services/purchase_service.dart`, `pubspec.yaml`.

### Issue 3 — Decrypted secrets not zeroed from memory (FIXED, with one documented residual limitation)

**Was:** The master-password `CharArray` in `VaultChannelHandler.kt` was
never zeroed after KEK derivation. `VaultStore.getEntryPassword()` returned
a plain (unzeroable) `String`.

**Fix:**
- Each master/export-password `CharArray` is now zeroed (`.fill('\u0000')`)
  immediately after its own `deriveKek()` call, inside the function that
  actually derives the KEK — `VaultStore.setupVault()`,
  `VaultStore.unlockWithMasterPassword()`, and both password paths in
  `VaultExportImportManager` (`exportVault`, `importVault`). Zeroing was
  deliberately *not* done at the `VaultChannelHandler.kt` creation site,
  because `importVault`'s export-password `CharArray` is captured by an
  async SAF file-picker callback and only consumed later — zeroing early
  would have wiped it before use and broken every vault import.
- `VaultStore.getEntryPassword()` changed from `String?` to `CharArray?`.
  `VaultChannelHandler`'s handler builds the final `String` only at the
  last possible moment (required by the Flutter platform channel, which
  only carries Strings) and zeroes its `CharArray` copy immediately after.
  `getFullEntry()` (native export path only) explicitly converts back to
  `String` — required because `org.json`'s `JSONObject`/`JSONArray` only
  serialize `String` values; handing them a raw `CharArray` would silently
  corrupt exported passwords into Java's default `Object.toString()`
  (`[C@hash`) instead of the actual password text — and zeroes its own
  `CharArray` right after.

**Residual, documented limitation:** the `org.json` parse inside
`getEntryPassword()` still produces one short-lived, unzeroable `String`
internally, since `org.json`'s API only accepts/returns `String`. This is
inherent to that library and not reachable without replacing the JSON
parser entirely — out of scope for this pass, called out in a code comment
at the call site.

`VaultCryptoManager.kt` (salt/IV/PBKDF2/key-wrap logic) was **not** touched.

**Files:** `android/.../vault/VaultStore.kt`,
`android/.../vault/VaultChannelHandler.kt`,
`android/.../vault/VaultExportImportManager.kt`.

### Verification (all three issues)

- `flutter analyze`: clean after each fix — same 225 pre-existing `info`-level
  lints (`deprecated_member_use` for `withOpacity`, one `annotate_overrides`),
  0 new issues introduced.
- `./gradlew :app:compileDebugKotlin`: BUILD SUCCESSFUL (needed since
  `flutter analyze` doesn't compile native Kotlin — this caught one
  incidental bug: a missing `android.os.Build` import from the Issue 1 edit,
  fixed before Issue 2 work began).
- `flutter test`: 116/116 passed after each fix.
- No crypto/salt/IV/Keystore/biometric code was modified in any of the
  three fixes.

### Next steps for a future session

1. Fill in `BASE64_PUBLIC_KEY` in `PurchaseChannelHandler.kt` with the real
   Play Console license key to activate Issue 2's signature enforcement.
2. If/when a backend is built, replace Issue 2's local-only verification
   with real server-side receipt validation.
