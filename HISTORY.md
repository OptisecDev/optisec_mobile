# OptiSec Mobile — Development History

A technical changelog of security reviews, hardening passes, and feature
milestones actually completed and verified in this repository. Entries are
chronological; each reflects work that was implemented, tested, and
committed — not work in progress. No keys, secrets, or contact details are
included.

---

## Initial architecture (v1.0)

Flutter/GetX security app for Android, built feature-first
(`lib/features/{dashboard,wifi_shield,privacy_guard,cyber_academy}`) with a
shared theme, model, and widget layer. Core modules from day one:

- **WiFi Shield** — real-time network scanning (`wifi_scan` +
  `network_info_plus`) with a computed risk score, not a canned demo value.
- **Privacy Guard** — Android runtime-permission auditing.
- **Cyber Academy** — in-app security education content.
- **Dashboard** — cross-module score aggregation, deliberately designed from
  the outset to compute its numbers from live module state rather than
  display placeholder/fabricated figures ("never fabricates a number" is an
  explicit invariant documented in the controller).
- Dark theme (`#00D4AA` on `#060A0F`), full Arabic/English localization via
  ARB files with RTL layout switching.

## Early stabilization

- Fixed an undefined `ThreatLevel` reference crashing `WifiShieldView`.
- Fixed an infinite scan loop in Privacy Guard and a GetX reactivity error
  in the lesson-detail sheet.
- Added the Settings tab to bottom navigation.
- Fixed two runtime crashes specific to the Linux desktop target.
- Replaced fragile GetX `Obx` reactivity in the lesson-step sheet with a
  plain `StatefulWidget` for more predictable rebuild behavior.

## Monetization foundation

- Added the Pro subscription paywall (`in_app_purchase`) with free-tier
  scan gating.
- Configured a signed Android release build.
- Fixed onboarding content overflow; replaced the default counter widget
  test with a real one.
- Added historical network-trust scoring to support cross-time Evil Twin
  detection; hardened `PurchaseService` to degrade gracefully on platforms
  without IAP support; closed an exhaustive-switch gap for a new
  `EvilTwinReason` case.
- Shipped v1.1.0 (CHANGELOG + store listing notes).

## Feature expansion

- **Threat Intel** — added, wired to a live threat-feed URL with a
  dashboard preview.
- **Privacy Guard** — added a permission-usage timeline using a
  foreground-time proxy, with proper error/retry state and lifecycle-aware
  refresh.
- **App Lock** — added PIN/biometric app locking with foreground-service
  detection, an overlay-first lock screen, and Pro-gated per-app selection.
- **Password Vault** — added a secure vault with biometric unlock, full
  entry CRUD, auto-lock, and encrypted export/import.

## Security audit remediation (2026-07-12)

A dedicated read-only security audit reviewed the app end to end. Core
cryptography — salt generation, IV generation, PBKDF2 parameters, Android
Keystore usage, and biometric key binding (`VaultCryptoManager.kt`) — was
confirmed correct and left untouched. Three real issues were found,
prioritized, and remediated:

1. **Privacy Guard fabricated per-app permission data.** Per-app
   `appNames`/`appsCount` were hardcoded placeholders, not derived from any
   device query. Fixed by adding a real `PackageManager`-backed native
   query (`getPermissionHolders` in `MainActivity.kt`) covering all six
   permission categories, reusing the app's existing usage-tracking
   pattern. On query failure the UI now falls back to an honest empty
   state rather than fabricated names.
2. **In-app purchase entitlement was trusted from `purchase.status` alone**,
   with no read of `verificationData`. Added local RSA/SHA1 signature
   verification against the Play Console license public key
   (`PurchaseChannelHandler.kt`, using the platform's built-in
   `java.security` — no new native dependency). Documented, accepted
   limitation: this is client-side hardening only, activated once the
   publisher's key is supplied; true tamper-resistance would require
   server-side receipt validation, which the app doesn't have a backend
   for yet.
3. **Decrypted vault secrets were never zeroed from memory.** Master and
   export-password `CharArray`s are now wiped immediately after key
   derivation in `VaultStore`/`VaultExportImportManager`; the vault's
   entry-password API was changed from `String` to `CharArray` end-to-end
   so callers can zero it themselves.

Verified via `flutter analyze` (no new issues), a Kotlin compile check, and
a full `flutter test` pass — with no changes to salt/IV/Keystore/biometric
code in any of the three fixes.

## App Lock test coverage

Added unit/controller test coverage for App Lock (`app_lock_service_test`,
`app_lock_controller_test`, `pin_setup_controller_test`), which surfaced
and fixed a real bug along the way: `restart()` wasn't clearing the
previous error message, so a stale PIN-mismatch error could persist across
a fresh attempt. The full project test suite passes at **193/193**.

## WiFi Shield / Evil Twin refinement

- Surfaced graduated Evil Twin confidence levels in the UI instead of a
  flat detected/not-detected signal.
- Dropped a dead `NEARBY_WIFI_DEVICES` manifest declaration and added a
  permission re-check on app resume.
- Clarified the last-scan network count and surfaced concrete scan-failure
  reasons to the user instead of a silent empty state.
- Fixed a GetX crash in the Evil Twin alert on its first render.

## Dashboard icon fix and app icon rebrand

- Fixed the dashboard security-tip icons: they were stored as raw `int`
  codepoints and wrapped in `IconData` only at render time, which broke
  tree-shaking/const-eval assumptions. `IconData` is now built once on the
  tip record itself (`DashboardController`), and `SecurityTipCard` just
  renders it directly.
- Regenerated the Android app icon as a proper branded adaptive icon
  (background/foreground/monochrome layers) via `flutter_launcher_icons`,
  sourced from new branding artwork under `assets/branding/`.
- Verified with `flutter analyze` (0 errors, same pre-existing info-level
  lints) and a full `flutter test` pass — **242/242**.

---

*This file tracks completed, verified work only. Work in progress is
tracked separately and added here once it lands and is tested.*
