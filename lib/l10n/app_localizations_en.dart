// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OptiSec';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get wifiShield => 'WiFi Shield';

  @override
  String get privacyGuard => 'Privacy Guard';

  @override
  String get cyberAcademy => 'Cyber Academy';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get scanning => 'Scanning...';

  @override
  String get securityScore => 'Security Score';

  @override
  String get threatsDetected => 'Threats Detected';

  @override
  String get networksScan => 'Networks Scanned';

  @override
  String get lastScan => 'Last Scan';

  @override
  String get safe => 'Safe';

  @override
  String get warning => 'Warning';

  @override
  String get danger => 'Danger';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get unknown => 'Unknown';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionLocationMsg =>
      'Location permission is required to scan WiFi networks.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get networkName => 'Network Name';

  @override
  String get signalStrength => 'Signal Strength';

  @override
  String get security => 'Security';

  @override
  String get channel => 'Channel';

  @override
  String get frequency => 'Frequency';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get macAddress => 'MAC Address';

  @override
  String get privacyScore => 'Privacy Score';

  @override
  String get appsWithAccess => 'Apps with Access';

  @override
  String get locationAccess => 'Location Access';

  @override
  String get cameraAccess => 'Camera Access';

  @override
  String get microphoneAccess => 'Microphone Access';

  @override
  String get contactsAccess => 'Contacts Access';

  @override
  String get lesson => 'Lesson';

  @override
  String get lessons => 'Lessons';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get notStarted => 'Not Started';

  @override
  String get startLesson => 'Start Lesson';

  @override
  String get continueLesson => 'Continue';

  @override
  String get phishingAwareness => 'Phishing Awareness';

  @override
  String get passwordSecurity => 'Password Security';

  @override
  String get networkSecurity => 'Network Security';

  @override
  String get dataPriacy => 'Data Privacy';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get passwordVault => 'Password Vault';

  @override
  String get vaultDashboardTileLabel => 'Password\nVault';

  @override
  String get vaultSearchHint => 'Search entries';

  @override
  String get vaultEmptyState => 'No saved passwords yet';

  @override
  String get vaultAddEntry => 'Add Entry';

  @override
  String get vaultLockVault => 'Lock Vault';

  @override
  String get vaultSetupTitle => 'Create Your Vault';

  @override
  String get vaultSetupSubtitle =>
      'Choose a master password to secure your vault';

  @override
  String get vaultMasterPasswordLabel => 'Master Password';

  @override
  String get vaultConfirmPasswordLabel => 'Confirm Password';

  @override
  String get vaultAckText =>
      'If you forget this password, your saved entries cannot be recovered.';

  @override
  String get vaultAckCheckbox =>
      'I understand this password cannot be recovered';

  @override
  String get vaultCreateVault => 'Create Vault';

  @override
  String get vaultUnlockTitle => 'Unlock Vault';

  @override
  String get vaultUnlockSubtitle => 'Enter your master password to continue';

  @override
  String get vaultUnlockButton => 'Unlock';

  @override
  String get vaultUseBiometric => 'Use Biometric Unlock';

  @override
  String get vaultEntryDetailTitle => 'Entry Details';

  @override
  String get vaultEntryEditTitleNew => 'New Entry';

  @override
  String get vaultEntryEditTitleEdit => 'Edit Entry';

  @override
  String get vaultFieldTitle => 'Title';

  @override
  String get vaultFieldUsername => 'Username';

  @override
  String get vaultFieldPassword => 'Password';

  @override
  String get vaultFieldUrl => 'Website';

  @override
  String get vaultFieldNotes => 'Notes';

  @override
  String get vaultReveal => 'Reveal';

  @override
  String get vaultHide => 'Hide';

  @override
  String get vaultCopy => 'Copy';

  @override
  String get vaultCopied => 'Copied — will clear automatically';

  @override
  String get vaultGeneratePassword => 'Generate';

  @override
  String get vaultSave => 'Save';

  @override
  String get vaultDelete => 'Delete';

  @override
  String get vaultDeleteConfirmTitle => 'Delete this entry?';

  @override
  String get vaultDeleteConfirmBody => 'This can\'t be undone.';

  @override
  String get vaultCancel => 'Cancel';

  @override
  String get vaultExportVault => 'Export Vault';

  @override
  String get vaultImportVault => 'Import Vault';

  @override
  String get vaultExportPasswordLabel => 'Export Password';

  @override
  String get vaultExportPasswordHint =>
      'Used only to protect the exported file';

  @override
  String get vaultExportButton => 'Export';

  @override
  String get vaultImportButton => 'Import';

  @override
  String get vaultImportMergeOption => 'Merge with existing entries';

  @override
  String get vaultImportReplaceOption => 'Replace all existing entries';

  @override
  String get vaultExportSuccess => 'Vault exported successfully';

  @override
  String get vaultExportWeakPassword =>
      'Export password must be at least 10 characters and mix character types';

  @override
  String get vaultExportReauthFailed => 'Incorrect master password';

  @override
  String get vaultExportCancelled => 'Export cancelled';

  @override
  String get vaultExportFailed => 'Export failed';

  @override
  String get vaultImportSuccess => 'Vault imported successfully';

  @override
  String get vaultImportBadPassword =>
      'Incorrect export password or corrupted file';

  @override
  String get vaultImportInvalidFile => 'Not a valid vault export file';

  @override
  String get vaultImportCancelled => 'Import cancelled';

  @override
  String get vaultImportFailed => 'Import failed';

  @override
  String get vaultImportNotUnlocked => 'Unlock the vault before importing';

  @override
  String get vaultAutoLockLabel => 'Auto-Lock';

  @override
  String get vaultAutoLockImmediate => 'Immediately';

  @override
  String get vaultAutoLockOneMinute => '1 minute';

  @override
  String get vaultAutoLockFiveMinutes => '5 minutes';

  @override
  String get vaultBiometricEnable => 'Enable Biometric Unlock';

  @override
  String get vaultBiometricDisable => 'Disable Biometric Unlock';

  @override
  String get vaultBiometricEnabled => 'Biometric unlock enabled';

  @override
  String get vaultBiometricEnableFailed => 'Couldn\'t enable biometric unlock';

  @override
  String get vaultErrorTitleRequired => 'Title is required';

  @override
  String get vaultErrorPasswordRequired => 'Password is required';

  @override
  String get vaultErrorSaveFailed => 'Couldn\'t save this entry. Try again.';

  @override
  String get vaultErrorPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get vaultErrorPasswordTooShort =>
      'Master password must be at least 8 characters';

  @override
  String get vaultErrorAckRequired =>
      'Please confirm you understand this password can\'t be recovered';

  @override
  String get vaultErrorCreateFailed => 'Couldn\'t create the vault. Try again.';

  @override
  String get vaultErrorIncorrectMasterPassword => 'Incorrect master password';

  @override
  String get vaultErrorTooManyAttempts => 'Too many failed attempts';

  @override
  String get vaultErrorBiometricChanged =>
      'Biometric enrollment changed — use your master password';

  @override
  String get vaultErrorBiometricFailed => 'Biometric authentication failed';

  @override
  String get vaultProLimitBanner =>
      'Free plan limit reached — upgrade to Pro for unlimited entries';

  @override
  String get wifiLocationPermissionTitle => 'Location Permission Required';

  @override
  String get wifiLocationPermissionBody =>
      'Android requires location access to scan nearby WiFi networks. OptiSec never uploads your location.';

  @override
  String get wifiScanAgain => 'Scan Again';

  @override
  String wifiNearbyNetworksCount(int count) {
    return 'Nearby Networks ($count)';
  }

  @override
  String wifiSafeNetworksCount(int count) {
    return 'Safe Networks ($count)';
  }

  @override
  String wifiThreatsCount(int count) {
    return 'Threats ($count)';
  }

  @override
  String wifiEvilTwinsCount(int count) {
    return 'Evil Twins ($count)';
  }

  @override
  String wifiNetworksCount(int count) {
    return 'Networks ($count)';
  }

  @override
  String get wifiUpdating => 'Updating…';

  @override
  String get wifiEmptyNoNetworks =>
      'No networks found.\nTap the radar icon to scan.';

  @override
  String get wifiEmptyNoMatch => 'No networks match this filter.';

  @override
  String get wifiScanningForNetworks => 'Scanning for networks…';

  @override
  String get wifiAnalyzingSignals => 'Analyzing signals and detecting threats';

  @override
  String get wifiThreatsLabel => 'Threats';

  @override
  String get wifiEvilTwinsLabel => 'Evil Twins';

  @override
  String get wifiTotalLabel => 'Total';

  @override
  String get wifiRiskyNetwork => 'Risky Network';

  @override
  String get wifiRiskLabel => 'RISK';

  @override
  String get wifiFilterAll => 'All';

  @override
  String get wifiSortLabel => 'Sort:';

  @override
  String get wifiSortSignal => 'Signal';

  @override
  String get wifiSortRisk => 'Risk';

  @override
  String get wifiSortName => 'Name';

  @override
  String get wifiEvilTwinDetectedTitle => 'Evil Twin Attack Detected!';

  @override
  String wifiEvilTwinBody(int count, String ssids) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rogue access points found impersonating $ssids',
      one: '$count rogue access point found impersonating $ssids',
    );
    return '$_temp0';
  }

  @override
  String get wifiEvilTwinPossibleTitle =>
      'Possible Network Duplication — Review Details';

  @override
  String wifiEvilTwinPossibleBody(int count, String ssids) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count access points using different hardware vendors were found broadcasting $ssids. This can happen with legitimate mesh or range-extender setups — review before assuming an attack.',
      one:
          '$count access point using a different hardware vendor was found broadcasting $ssids. This can happen with legitimate mesh or range-extender setups — review before assuming an attack.',
    );
    return '$_temp0';
  }

  @override
  String get wifiEvilTwinConfidenceHigh => 'High risk';

  @override
  String get wifiEvilTwinConfidenceMedium => 'Medium risk';

  @override
  String get wifiEvilTwinPossibleStrip => 'Possible Duplicate';

  @override
  String get wifiReasonVendorMismatch => 'Vendor Mismatch';

  @override
  String get wifiReasonSecurityDowngrade => 'Security Downgrade';

  @override
  String get wifiReasonSignalAnomaly => 'Signal Anomaly';

  @override
  String get wifiReasonOpenImpersonation => 'Open Impersonation';

  @override
  String get wifiReasonBssidChanged => 'BSSID Changed';

  @override
  String get wifiDismiss => 'Dismiss';

  @override
  String get wifiViewThreats => 'View Threats';

  @override
  String get wifiEvilTwinChip => 'Evil Twin';

  @override
  String get wifiEvilTwinIndicatorsTitle => 'Evil Twin Attack Indicators';

  @override
  String get wifiReasonDescDifferentOui =>
      'Different hardware vendor broadcasting same SSID — OUI mismatch detected';

  @override
  String get wifiReasonDescSecurityDowngrade =>
      'Weaker encryption than other APs with the same name — downgrade attack suspected';

  @override
  String get wifiReasonDescSignalAnomaly =>
      'Hidden network with abnormally strong signal suggests a rogue access point nearby';

  @override
  String get wifiReasonDescOpenImpersonation =>
      'Open network impersonating a secured SSID — honeypot or captive portal attack';

  @override
  String get wifiReasonDescHistoricalBssidChange =>
      'SSID previously seen with a different BSSID — possible access point spoofing';

  @override
  String get wifiDetailSignal => 'Signal';

  @override
  String get wifiDetailBand => 'Band';

  @override
  String get wifiDetailVendorOui => 'Vendor OUI';

  @override
  String get wifiDetectedThreatsTitle => 'Detected Threats';

  @override
  String get wifiRiskBreakdownTitle => 'Risk Breakdown';

  @override
  String get wifiRiskEncryption => 'Encryption';

  @override
  String get wifiRiskOpenNetwork => 'Open Network';

  @override
  String get wifiEvilTwinDetectedStrip => 'Evil Twin Detected';

  @override
  String wifiChipChannel(int channel) {
    return 'Ch $channel';
  }

  @override
  String wifiMoreThreatsTapToView(int count) {
    return '+$count more — tap to view';
  }

  @override
  String get wifiShortReasonOui => 'OUI Mismatch';

  @override
  String get wifiShortReasonDowngrade => 'Downgrade';

  @override
  String get wifiShortReasonSignal => 'Signal';

  @override
  String get wifiShortReasonHoneypot => 'Honeypot';

  @override
  String get wifiRiskCritical => 'Critical';

  @override
  String get wifiRiskHigh => 'High';

  @override
  String get wifiRiskMedium => 'Medium';

  @override
  String get wifiRiskLow => 'Low';

  @override
  String get wifiHiddenNetworkLabel => '(Hidden Network)';

  @override
  String get wifiThreatOpenNetwork => 'Open network — traffic is unencrypted';

  @override
  String get wifiThreatWepBroken =>
      'WEP encryption is cryptographically broken';

  @override
  String wifiThreatMultipleVendors(String ssid) {
    return 'Multiple vendors broadcasting \"$ssid\" — possible Evil Twin';
  }

  @override
  String wifiThreatOpenClone(String ssid) {
    return 'Open clone of secured network \"$ssid\" — honeypot suspected';
  }

  @override
  String wifiThreatWeakerEncryption(String ssid) {
    return 'Weaker encryption than other \"$ssid\" APs';
  }

  @override
  String get wifiThreatHiddenStrongSignal =>
      'Hidden AP with very strong signal — possible rogue device';

  @override
  String wifiThreatHistoricalChange(String ssid) {
    return 'Access point hardware changed for \"$ssid\" — possible historical Evil Twin';
  }

  @override
  String get wifiUnlimitedScansFeature => 'Unlimited WiFi scans';

  @override
  String get privacyScanningPermissions => 'Scanning permissions…';

  @override
  String privacyHighRiskGrantedSubtitle(int highRisk, int granted) {
    return '$highRisk high-risk · $granted granted';
  }

  @override
  String get privacyScoreDescExcellent =>
      'Your privacy is well protected. Keep reviewing new app installs.';

  @override
  String get privacyScoreDescGood =>
      'Some permissions need attention. Review the recommendations below.';

  @override
  String get privacyScoreDescPoor =>
      'Several high-risk permissions are active. Take action now.';

  @override
  String get privacyScoreDescCritical =>
      'Critical privacy exposure detected. Revoke sensitive permissions immediately.';

  @override
  String get privacyBulletHighRisk => 'High risk';

  @override
  String get privacyBulletMediumRisk => 'Medium risk';

  @override
  String get privacyBulletProtected => 'Protected';

  @override
  String get privacySummaryHighRisk => 'High Risk';

  @override
  String get privacySummaryMediumRisk => 'Medium Risk';

  @override
  String get privacyLowRisk => 'Low Risk';

  @override
  String get privacyRiskBreakdownTitle => 'Permission Risk Breakdown';

  @override
  String get privacyNoPermissionData => 'No permission data yet.';

  @override
  String get privacyLegendHigh => 'High';

  @override
  String get privacyLegendMedium => 'Medium';

  @override
  String get privacyExposureTitle => 'Data Exposure by Permission';

  @override
  String get privacyAppsGrantedLabel => '# apps granted';

  @override
  String get privacyRecommendationsTitle => 'Recommendations';

  @override
  String get privacyAppPermissionsTitle => 'App Permissions';

  @override
  String get privacyNoPermissionsMatch => 'No permissions match this filter.';

  @override
  String get privacyFilterAll => 'All';

  @override
  String get privacyFilterGranted => 'Granted';

  @override
  String get privacyUsageTimelineTitle => 'Permission Usage Timeline';

  @override
  String get privacyProBadge => 'PRO';

  @override
  String get privacyUsageTimelineDesc1 =>
      'Which apps with camera, microphone, or location access were recently open.';

  @override
  String get privacyUsageTimelineDesc2 =>
      'Based on foreground app time, not confirmed sensor access.';

  @override
  String get privacyUsageTimelineEmpty =>
      'No apps with camera, microphone, or location access were open in the last 7 days.';

  @override
  String get privacyOpenSettings => 'Open Settings';

  @override
  String get privacyRetry => 'Retry';

  @override
  String get privacyLoadUsageTimeline => 'Load Usage Timeline';

  @override
  String get privacyUsageAccessNotGranted =>
      'Usage Access isn\'t granted yet. Enable it for OptiSec in system settings, then tap Retry.';

  @override
  String get privacyUsageAccessExplain =>
      'Requires \"Usage Access\" to be granted in system settings. This lets OptiSec see which apps were recently open — it does not grant access to any personal data.';

  @override
  String get privacyUsageLoadError => 'Couldn\'t load the usage timeline.';

  @override
  String get privacyWhatPermissionDoes => 'What This Permission Does';

  @override
  String get privacyRecommendationTitle => 'Recommendation';

  @override
  String get privacyOpenSettingsToRevoke => 'Open Settings to Revoke';

  @override
  String get privacyPermissionDeniedProtected =>
      'Permission Denied — You\'re Protected';

  @override
  String get privacyStatusLabel => 'Status';

  @override
  String get privacyAppsLabel => 'Apps';

  @override
  String get privacyRiskLevelLabel => 'Risk Level';

  @override
  String get privacyGranted => 'Granted';

  @override
  String get privacyDenied => 'Denied';

  @override
  String privacyAppsCountChip(int count) {
    return '$count apps';
  }

  @override
  String get privacyRevoke => 'Revoke';

  @override
  String get privacyDeniedCheck => 'Denied ✓';

  @override
  String get privacyNever => 'Never';

  @override
  String get privacyJustNow => 'Just now';

  @override
  String privacyMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String privacyHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String privacyDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get privacyOpenNow => 'Open now';

  @override
  String privacyTimesPerWeek(int count) {
    return '$count× / 7d';
  }

  @override
  String get privacyRecMicTitle => 'Restrict Microphone Access';

  @override
  String get privacyRecMicBody =>
      'You have 4 apps with permanent microphone access. Only voice/call apps need it.';

  @override
  String get privacyRecMicAction => 'Review Mic Apps';

  @override
  String get privacyRecLocationTitle => 'Use \"While Using\" for Location';

  @override
  String get privacyRecLocationBody =>
      'Switch location permission from \"Always\" to \"Only while using the app.\"';

  @override
  String get privacyRecLocationAction => 'Update Location';

  @override
  String get privacyRecContactsTitle => 'Limit Contacts Access';

  @override
  String get privacyRecContactsBody =>
      '5 apps can read your full contact list. Restrict to messaging apps only.';

  @override
  String get privacyRecContactsAction => 'Review Contacts';

  @override
  String get privacyFix => 'Fix';

  @override
  String get privacyScanCompleteTitle => 'Privacy Scan Complete';

  @override
  String privacyScanCompleteBody(int highRisk, int mediumRisk) {
    return 'Found $highRisk high-risk and $mediumRisk medium-risk permissions.';
  }

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionScanning => 'Security Scanning';

  @override
  String get settingsSectionPrivacyLock => 'Privacy & Lock';

  @override
  String get settingsSectionData => 'Data';

  @override
  String settingsVersionBuild(String version, String build) {
    return 'v$version (Build $build)';
  }

  @override
  String get settingsAllSystemsProtected => 'All systems protected';

  @override
  String get settingsFreePlanSubtitle =>
      'Free plan — enter a license key to unlock Pro';

  @override
  String settingsLifetimeLicenseWithLabel(String label) {
    return 'Lifetime license · $label';
  }

  @override
  String get settingsLifetimeLicense => 'Lifetime license';

  @override
  String settingsValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get settingsProActive => 'OptiSec Pro — Active';

  @override
  String get settingsProInactive => 'OptiSec Pro';

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsFreeBadge => 'FREE';

  @override
  String get settingsLanguageSubtitle => 'App display language';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Display theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsAutoScanTitle => 'Auto Scan';

  @override
  String get settingsAutoScanSubtitle => 'Periodically scan for threats';

  @override
  String get settingsScanIntervalTitle => 'Scan Interval';

  @override
  String get settingsScanIntervalSubtitle => 'How often to run auto scans';

  @override
  String get settingsEvilTwinAlertsTitle => 'Evil Twin Alerts';

  @override
  String get settingsEvilTwinAlertsSubtitle =>
      'Warn when a rogue access point is detected';

  @override
  String get settingsVpnDetectionTitle => 'VPN Detection';

  @override
  String get settingsVpnDetectionSubtitle => 'Detect active VPN connections';

  @override
  String get settingsScanIntervalPrompt =>
      'How often should OptiSec scan for threats?';

  @override
  String settingsEveryMinutes(int minutes) {
    return 'Every $minutes minutes';
  }

  @override
  String get settingsEveryHour => 'Every hour';

  @override
  String get settingsFreqHigh => 'High frequency — more battery usage';

  @override
  String get settingsFreqBalanced => 'Balanced — recommended';

  @override
  String get settingsFreqLow => 'Low frequency — minimal battery usage';

  @override
  String get settingsPushNotifTitle => 'Push Notifications';

  @override
  String get settingsPushNotifSubtitle => 'Allow OptiSec to send notifications';

  @override
  String get settingsThreatAlertsTitle => 'Threat Alerts';

  @override
  String get settingsThreatAlertsSubtitle =>
      'Immediate alerts for detected threats';

  @override
  String get settingsWeeklyReportTitle => 'Weekly Security Report';

  @override
  String get settingsWeeklyReportSubtitle =>
      'Summary of threats and scans each week';

  @override
  String get settingsExportReportTitle => 'Export Security Report';

  @override
  String get settingsExportReportSubtitle =>
      'Share a PDF summary of your current security status';

  @override
  String get settingsExportReportAction => 'Export';

  @override
  String get settingsExportReportExportingAction => 'Exporting…';

  @override
  String get settingsExportReportFailedTitle => 'Export Failed';

  @override
  String get settingsExportReportFailedBody =>
      'Could not generate the PDF report. Please try again.';

  @override
  String get settingsBiometricLockTitle => 'Biometric Lock';

  @override
  String get settingsBiometricLockSubtitle =>
      'Require fingerprint or Face ID to open app';

  @override
  String get settingsAppLockTitle => 'App Lock';

  @override
  String get settingsAppLockSubtitle =>
      'PIN or biometric protection for individual apps';

  @override
  String get settingsUsageAnalyticsTitle => 'Usage Analytics';

  @override
  String get settingsUsageAnalyticsSubtitle =>
      'Share anonymous usage data to improve the app';

  @override
  String get settingsRateAppTitle => 'Rate OptiSec';

  @override
  String get settingsRateAppSubtitle => 'Leave a review on the App Store';

  @override
  String get settingsOpeningAppStore => 'Opening App Store…';

  @override
  String get settingsShareAppTitle => 'Share App';

  @override
  String get settingsShareAppSubtitle => 'Tell your friends about OptiSec';

  @override
  String get settingsOpeningShareSheet => 'Opening share sheet…';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsOpeningPrivacyPolicy => 'Opening Privacy Policy…';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsOpeningTerms => 'Opening Terms of Service…';

  @override
  String settingsVersionShort(String version, String build) {
    return 'v$version ($build)';
  }

  @override
  String get settingsClearHistoryTitle => 'Clear Scan History';

  @override
  String get settingsClearHistorySubtitle => 'Remove all saved scan results';

  @override
  String get settingsClearAction => 'Clear';

  @override
  String get settingsResetAllTitle => 'Reset All Data';

  @override
  String get settingsResetAllSubtitle =>
      'Erase everything and restore defaults';

  @override
  String get settingsResettingAction => 'Resetting…';

  @override
  String get settingsResetAction => 'Reset';

  @override
  String get settingsClearHistoryConfirmTitle => 'Clear Scan History?';

  @override
  String get settingsClearHistoryConfirmBody =>
      'This will remove all saved scan results. Your settings will not be affected.';

  @override
  String get settingsResetAllConfirmTitle => 'Reset All Data?';

  @override
  String get settingsResetAllConfirmBody =>
      'This will erase all scan history, threat records, and restore all settings to their defaults. This cannot be undone.';

  @override
  String get settingsResetEverythingAction => 'Reset Everything';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsHistoryClearedTitle => 'History Cleared';

  @override
  String get settingsHistoryClearedBody => 'Scan history has been erased.';

  @override
  String get settingsDataResetTitle => 'Data Reset';

  @override
  String get settingsDataResetBody =>
      'All settings and scan data have been cleared.';
}
