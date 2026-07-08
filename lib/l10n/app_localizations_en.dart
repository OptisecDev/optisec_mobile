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
}
