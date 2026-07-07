# Changelog

All notable changes to OptiSec Mobile are documented in this file.

## [1.1.0] - 2026-07-07

### Added
- Historical network trust scoring for cross-time Evil Twin detection — networks are tracked over time so repeated visits to a trusted network are distinguished from a spoofed Evil Twin appearing later.

### Fixed
- `PurchaseService` now degrades gracefully on unsupported platforms instead of failing.
- Exhaustive switch handling added for the new `EvilTwinReason` case.

## [1.0.0] - 2026-06-26

### Added
- Initial release.
