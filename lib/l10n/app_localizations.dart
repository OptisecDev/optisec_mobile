import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OptiSec'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @wifiShield.
  ///
  /// In en, this message translates to:
  /// **'WiFi Shield'**
  String get wifiShield;

  /// No description provided for @privacyGuard.
  ///
  /// In en, this message translates to:
  /// **'Privacy Guard'**
  String get privacyGuard;

  /// No description provided for @cyberAcademy.
  ///
  /// In en, this message translates to:
  /// **'Cyber Academy'**
  String get cyberAcademy;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @securityScore.
  ///
  /// In en, this message translates to:
  /// **'Security Score'**
  String get securityScore;

  /// No description provided for @threatsDetected.
  ///
  /// In en, this message translates to:
  /// **'Threats Detected'**
  String get threatsDetected;

  /// No description provided for @networksScan.
  ///
  /// In en, this message translates to:
  /// **'Networks Scanned'**
  String get networksScan;

  /// No description provided for @lastScan.
  ///
  /// In en, this message translates to:
  /// **'Last Scan'**
  String get lastScan;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @danger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get danger;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionLocationMsg.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to scan WiFi networks.'**
  String get permissionLocationMsg;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Network Name'**
  String get networkName;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal Strength'**
  String get signalStrength;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @macAddress.
  ///
  /// In en, this message translates to:
  /// **'MAC Address'**
  String get macAddress;

  /// No description provided for @privacyScore.
  ///
  /// In en, this message translates to:
  /// **'Privacy Score'**
  String get privacyScore;

  /// No description provided for @appsWithAccess.
  ///
  /// In en, this message translates to:
  /// **'Apps with Access'**
  String get appsWithAccess;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// No description provided for @cameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraAccess;

  /// No description provided for @microphoneAccess.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get microphoneAccess;

  /// No description provided for @contactsAccess.
  ///
  /// In en, this message translates to:
  /// **'Contacts Access'**
  String get contactsAccess;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLesson;

  /// No description provided for @phishingAwareness.
  ///
  /// In en, this message translates to:
  /// **'Phishing Awareness'**
  String get phishingAwareness;

  /// No description provided for @passwordSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password Security'**
  String get passwordSecurity;

  /// No description provided for @networkSecurity.
  ///
  /// In en, this message translates to:
  /// **'Network Security'**
  String get networkSecurity;

  /// No description provided for @dataPriacy.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy'**
  String get dataPriacy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @passwordVault.
  ///
  /// In en, this message translates to:
  /// **'Password Vault'**
  String get passwordVault;

  /// No description provided for @vaultDashboardTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Password\nVault'**
  String get vaultDashboardTileLabel;

  /// No description provided for @vaultSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search entries'**
  String get vaultSearchHint;

  /// No description provided for @vaultEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No saved passwords yet'**
  String get vaultEmptyState;

  /// No description provided for @vaultAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get vaultAddEntry;

  /// No description provided for @vaultLockVault.
  ///
  /// In en, this message translates to:
  /// **'Lock Vault'**
  String get vaultLockVault;

  /// No description provided for @vaultSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Vault'**
  String get vaultSetupTitle;

  /// No description provided for @vaultSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a master password to secure your vault'**
  String get vaultSetupSubtitle;

  /// No description provided for @vaultMasterPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get vaultMasterPasswordLabel;

  /// No description provided for @vaultConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get vaultConfirmPasswordLabel;

  /// No description provided for @vaultAckText.
  ///
  /// In en, this message translates to:
  /// **'If you forget this password, your saved entries cannot be recovered.'**
  String get vaultAckText;

  /// No description provided for @vaultAckCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand this password cannot be recovered'**
  String get vaultAckCheckbox;

  /// No description provided for @vaultCreateVault.
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get vaultCreateVault;

  /// No description provided for @vaultUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Vault'**
  String get vaultUnlockTitle;

  /// No description provided for @vaultUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to continue'**
  String get vaultUnlockSubtitle;

  /// No description provided for @vaultUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get vaultUnlockButton;

  /// No description provided for @vaultUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric Unlock'**
  String get vaultUseBiometric;

  /// No description provided for @vaultEntryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry Details'**
  String get vaultEntryDetailTitle;

  /// No description provided for @vaultEntryEditTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get vaultEntryEditTitleNew;

  /// No description provided for @vaultEntryEditTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get vaultEntryEditTitleEdit;

  /// No description provided for @vaultFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get vaultFieldTitle;

  /// No description provided for @vaultFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get vaultFieldUsername;

  /// No description provided for @vaultFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get vaultFieldPassword;

  /// No description provided for @vaultFieldUrl.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get vaultFieldUrl;

  /// No description provided for @vaultFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get vaultFieldNotes;

  /// No description provided for @vaultReveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get vaultReveal;

  /// No description provided for @vaultHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get vaultHide;

  /// No description provided for @vaultCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get vaultCopy;

  /// No description provided for @vaultCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied — will clear automatically'**
  String get vaultCopied;

  /// No description provided for @vaultGeneratePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get vaultGeneratePassword;

  /// No description provided for @vaultSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get vaultSave;

  /// No description provided for @vaultDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get vaultDelete;

  /// No description provided for @vaultDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get vaultDeleteConfirmTitle;

  /// No description provided for @vaultDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get vaultDeleteConfirmBody;

  /// No description provided for @vaultCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get vaultCancel;

  /// No description provided for @vaultExportVault.
  ///
  /// In en, this message translates to:
  /// **'Export Vault'**
  String get vaultExportVault;

  /// No description provided for @vaultImportVault.
  ///
  /// In en, this message translates to:
  /// **'Import Vault'**
  String get vaultImportVault;

  /// No description provided for @vaultExportPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Export Password'**
  String get vaultExportPasswordLabel;

  /// No description provided for @vaultExportPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Used only to protect the exported file'**
  String get vaultExportPasswordHint;

  /// No description provided for @vaultExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get vaultExportButton;

  /// No description provided for @vaultImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get vaultImportButton;

  /// No description provided for @vaultImportMergeOption.
  ///
  /// In en, this message translates to:
  /// **'Merge with existing entries'**
  String get vaultImportMergeOption;

  /// No description provided for @vaultImportReplaceOption.
  ///
  /// In en, this message translates to:
  /// **'Replace all existing entries'**
  String get vaultImportReplaceOption;

  /// No description provided for @vaultExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vault exported successfully'**
  String get vaultExportSuccess;

  /// No description provided for @vaultExportWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Export password must be at least 10 characters and mix character types'**
  String get vaultExportWeakPassword;

  /// No description provided for @vaultExportReauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Incorrect master password'**
  String get vaultExportReauthFailed;

  /// No description provided for @vaultExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get vaultExportCancelled;

  /// No description provided for @vaultExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get vaultExportFailed;

  /// No description provided for @vaultImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vault imported successfully'**
  String get vaultImportSuccess;

  /// No description provided for @vaultImportBadPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect export password or corrupted file'**
  String get vaultImportBadPassword;

  /// No description provided for @vaultImportInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Not a valid vault export file'**
  String get vaultImportInvalidFile;

  /// No description provided for @vaultImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled'**
  String get vaultImportCancelled;

  /// No description provided for @vaultImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get vaultImportFailed;

  /// No description provided for @vaultImportNotUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock the vault before importing'**
  String get vaultImportNotUnlocked;

  /// No description provided for @vaultAutoLockLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock'**
  String get vaultAutoLockLabel;

  /// No description provided for @vaultAutoLockImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get vaultAutoLockImmediate;

  /// No description provided for @vaultAutoLockOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get vaultAutoLockOneMinute;

  /// No description provided for @vaultAutoLockFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get vaultAutoLockFiveMinutes;

  /// No description provided for @vaultBiometricEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Unlock'**
  String get vaultBiometricEnable;

  /// No description provided for @vaultBiometricDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Biometric Unlock'**
  String get vaultBiometricDisable;

  /// No description provided for @vaultBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock enabled'**
  String get vaultBiometricEnabled;

  /// No description provided for @vaultBiometricEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t enable biometric unlock'**
  String get vaultBiometricEnableFailed;

  /// No description provided for @vaultErrorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get vaultErrorTitleRequired;

  /// No description provided for @vaultErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get vaultErrorPasswordRequired;

  /// No description provided for @vaultErrorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this entry. Try again.'**
  String get vaultErrorSaveFailed;

  /// No description provided for @vaultErrorPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get vaultErrorPasswordsDontMatch;

  /// No description provided for @vaultErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Master password must be at least 8 characters'**
  String get vaultErrorPasswordTooShort;

  /// No description provided for @vaultErrorAckRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you understand this password can\'t be recovered'**
  String get vaultErrorAckRequired;

  /// No description provided for @vaultErrorCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the vault. Try again.'**
  String get vaultErrorCreateFailed;

  /// No description provided for @vaultErrorIncorrectMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect master password'**
  String get vaultErrorIncorrectMasterPassword;

  /// No description provided for @vaultErrorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts'**
  String get vaultErrorTooManyAttempts;

  /// No description provided for @vaultErrorBiometricChanged.
  ///
  /// In en, this message translates to:
  /// **'Biometric enrollment changed — use your master password'**
  String get vaultErrorBiometricChanged;

  /// No description provided for @vaultErrorBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get vaultErrorBiometricFailed;

  /// No description provided for @vaultProLimitBanner.
  ///
  /// In en, this message translates to:
  /// **'Free plan limit reached — upgrade to Pro for unlimited entries'**
  String get vaultProLimitBanner;

  /// No description provided for @wifiLocationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get wifiLocationPermissionTitle;

  /// No description provided for @wifiLocationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Android requires location access to scan nearby WiFi networks. OptiSec never uploads your location.'**
  String get wifiLocationPermissionBody;

  /// No description provided for @wifiScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get wifiScanAgain;

  ///
  ///
  /// In en, this message translates to:
  /// **'Nearby Networks ({count})'**
  String wifiNearbyNetworksCount(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Safe Networks ({count})'**
  String wifiSafeNetworksCount(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Threats ({count})'**
  String wifiThreatsCount(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Evil Twins ({count})'**
  String wifiEvilTwinsCount(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Networks ({count})'**
  String wifiNetworksCount(int count);

  /// No description provided for @wifiUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get wifiUpdating;

  /// No description provided for @wifiEmptyNoNetworks.
  ///
  /// In en, this message translates to:
  /// **'No networks found.\nTap the radar icon to scan.'**
  String get wifiEmptyNoNetworks;

  /// No description provided for @wifiEmptyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No networks match this filter.'**
  String get wifiEmptyNoMatch;

  /// No description provided for @wifiScanErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Grant location access in Settings to scan for WiFi networks.'**
  String get wifiScanErrorPermissionDenied;

  /// No description provided for @wifiScanErrorLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services (GPS) are turned off. Enable them in your device settings to scan for WiFi networks.'**
  String get wifiScanErrorLocationServiceDisabled;

  /// No description provided for @wifiScanErrorLocationAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Precise location is required to scan for WiFi networks. Switch to Precise Location in Settings.'**
  String get wifiScanErrorLocationAccuracy;

  /// No description provided for @wifiScanErrorNotSupported.
  ///
  /// In en, this message translates to:
  /// **'WiFi scanning is not supported on this device.'**
  String get wifiScanErrorNotSupported;

  /// No description provided for @wifiScanErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Scan failed. Please try again.'**
  String get wifiScanErrorGeneric;

  /// No description provided for @wifiScanningForNetworks.
  ///
  /// In en, this message translates to:
  /// **'Scanning for networks…'**
  String get wifiScanningForNetworks;

  /// No description provided for @wifiAnalyzingSignals.
  ///
  /// In en, this message translates to:
  /// **'Analyzing signals and detecting threats'**
  String get wifiAnalyzingSignals;

  /// No description provided for @wifiThreatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Threats'**
  String get wifiThreatsLabel;

  /// No description provided for @wifiEvilTwinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Evil Twins'**
  String get wifiEvilTwinsLabel;

  /// No description provided for @wifiTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get wifiTotalLabel;

  /// No description provided for @wifiRiskyNetwork.
  ///
  /// In en, this message translates to:
  /// **'Risky Network'**
  String get wifiRiskyNetwork;

  /// No description provided for @wifiRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'RISK'**
  String get wifiRiskLabel;

  /// No description provided for @wifiFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get wifiFilterAll;

  /// No description provided for @wifiSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get wifiSortLabel;

  /// No description provided for @wifiSortSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get wifiSortSignal;

  /// No description provided for @wifiSortRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get wifiSortRisk;

  /// No description provided for @wifiSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wifiSortName;

  /// No description provided for @wifiEvilTwinDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin Attack Detected!'**
  String get wifiEvilTwinDetectedTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one{{count} rogue access point found impersonating {ssids}} other{{count} rogue access points found impersonating {ssids}}}'**
  String wifiEvilTwinBody(int count, String ssids);

  /// No description provided for @wifiEvilTwinPossibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible Network Duplication — Review Details'**
  String get wifiEvilTwinPossibleTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one{{count} access point using a different hardware vendor was found broadcasting {ssids}. This can happen with legitimate mesh or range-extender setups — review before assuming an attack.} other{{count} access points using different hardware vendors were found broadcasting {ssids}. This can happen with legitimate mesh or range-extender setups — review before assuming an attack.}}'**
  String wifiEvilTwinPossibleBody(int count, String ssids);

  /// No description provided for @wifiEvilTwinConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get wifiEvilTwinConfidenceHigh;

  /// No description provided for @wifiEvilTwinConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium risk'**
  String get wifiEvilTwinConfidenceMedium;

  /// No description provided for @wifiEvilTwinPossibleStrip.
  ///
  /// In en, this message translates to:
  /// **'Possible Duplicate'**
  String get wifiEvilTwinPossibleStrip;

  /// No description provided for @wifiReasonVendorMismatch.
  ///
  /// In en, this message translates to:
  /// **'Vendor Mismatch'**
  String get wifiReasonVendorMismatch;

  /// No description provided for @wifiReasonSecurityDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Security Downgrade'**
  String get wifiReasonSecurityDowngrade;

  /// No description provided for @wifiReasonSignalAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Signal Anomaly'**
  String get wifiReasonSignalAnomaly;

  /// No description provided for @wifiReasonOpenImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Open Impersonation'**
  String get wifiReasonOpenImpersonation;

  /// No description provided for @wifiReasonBssidChanged.
  ///
  /// In en, this message translates to:
  /// **'BSSID Changed'**
  String get wifiReasonBssidChanged;

  /// No description provided for @wifiDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get wifiDismiss;

  /// No description provided for @wifiViewThreats.
  ///
  /// In en, this message translates to:
  /// **'View Threats'**
  String get wifiViewThreats;

  /// No description provided for @wifiEvilTwinChip.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin'**
  String get wifiEvilTwinChip;

  /// No description provided for @wifiEvilTwinIndicatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin Attack Indicators'**
  String get wifiEvilTwinIndicatorsTitle;

  /// No description provided for @wifiReasonDescDifferentOui.
  ///
  /// In en, this message translates to:
  /// **'Different hardware vendor broadcasting same SSID — OUI mismatch detected'**
  String get wifiReasonDescDifferentOui;

  /// No description provided for @wifiReasonDescSecurityDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Weaker encryption than other APs with the same name — downgrade attack suspected'**
  String get wifiReasonDescSecurityDowngrade;

  /// No description provided for @wifiReasonDescSignalAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Hidden network with abnormally strong signal suggests a rogue access point nearby'**
  String get wifiReasonDescSignalAnomaly;

  /// No description provided for @wifiReasonDescOpenImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Open network impersonating a secured SSID — honeypot or captive portal attack'**
  String get wifiReasonDescOpenImpersonation;

  /// No description provided for @wifiReasonDescHistoricalBssidChange.
  ///
  /// In en, this message translates to:
  /// **'SSID previously seen with a different BSSID — possible access point spoofing'**
  String get wifiReasonDescHistoricalBssidChange;

  /// No description provided for @wifiDetailSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get wifiDetailSignal;

  /// No description provided for @wifiDetailBand.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get wifiDetailBand;

  /// No description provided for @wifiDetailVendorOui.
  ///
  /// In en, this message translates to:
  /// **'Vendor OUI'**
  String get wifiDetailVendorOui;

  /// No description provided for @wifiDetectedThreatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected Threats'**
  String get wifiDetectedThreatsTitle;

  /// No description provided for @wifiRiskBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Breakdown'**
  String get wifiRiskBreakdownTitle;

  /// No description provided for @wifiRiskEncryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get wifiRiskEncryption;

  /// No description provided for @wifiRiskOpenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Open Network'**
  String get wifiRiskOpenNetwork;

  /// No description provided for @wifiEvilTwinDetectedStrip.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin Detected'**
  String get wifiEvilTwinDetectedStrip;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ch {channel}'**
  String wifiChipChannel(int channel);

  ///
  ///
  /// In en, this message translates to:
  /// **'+{count} more — tap to view'**
  String wifiMoreThreatsTapToView(int count);

  /// No description provided for @wifiShortReasonOui.
  ///
  /// In en, this message translates to:
  /// **'OUI Mismatch'**
  String get wifiShortReasonOui;

  /// No description provided for @wifiShortReasonDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get wifiShortReasonDowngrade;

  /// No description provided for @wifiShortReasonSignal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get wifiShortReasonSignal;

  /// No description provided for @wifiShortReasonHoneypot.
  ///
  /// In en, this message translates to:
  /// **'Honeypot'**
  String get wifiShortReasonHoneypot;

  /// No description provided for @wifiRiskCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get wifiRiskCritical;

  /// No description provided for @wifiRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get wifiRiskHigh;

  /// No description provided for @wifiRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get wifiRiskMedium;

  /// No description provided for @wifiRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get wifiRiskLow;

  /// No description provided for @wifiHiddenNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'(Hidden Network)'**
  String get wifiHiddenNetworkLabel;

  /// No description provided for @wifiThreatOpenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Open network — traffic is unencrypted'**
  String get wifiThreatOpenNetwork;

  /// No description provided for @wifiThreatWepBroken.
  ///
  /// In en, this message translates to:
  /// **'WEP encryption is cryptographically broken'**
  String get wifiThreatWepBroken;

  ///
  ///
  /// In en, this message translates to:
  /// **'Multiple vendors broadcasting \"{ssid}\" — possible Evil Twin'**
  String wifiThreatMultipleVendors(String ssid);

  ///
  ///
  /// In en, this message translates to:
  /// **'Open clone of secured network \"{ssid}\" — honeypot suspected'**
  String wifiThreatOpenClone(String ssid);

  ///
  ///
  /// In en, this message translates to:
  /// **'Weaker encryption than other \"{ssid}\" APs'**
  String wifiThreatWeakerEncryption(String ssid);

  /// No description provided for @wifiThreatHiddenStrongSignal.
  ///
  /// In en, this message translates to:
  /// **'Hidden AP with very strong signal — possible rogue device'**
  String get wifiThreatHiddenStrongSignal;

  ///
  ///
  /// In en, this message translates to:
  /// **'Access point hardware changed for \"{ssid}\" — possible historical Evil Twin'**
  String wifiThreatHistoricalChange(String ssid);

  /// No description provided for @wifiUnlimitedScansFeature.
  ///
  /// In en, this message translates to:
  /// **'Unlimited WiFi scans'**
  String get wifiUnlimitedScansFeature;

  /// No description provided for @privacyScanningPermissions.
  ///
  /// In en, this message translates to:
  /// **'Scanning permissions…'**
  String get privacyScanningPermissions;

  ///
  ///
  /// In en, this message translates to:
  /// **'{highRisk} high-risk · {granted} granted'**
  String privacyHighRiskGrantedSubtitle(int highRisk, int granted);

  /// No description provided for @privacyScoreDescExcellent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is well protected. Keep reviewing new app installs.'**
  String get privacyScoreDescExcellent;

  /// No description provided for @privacyScoreDescGood.
  ///
  /// In en, this message translates to:
  /// **'Some permissions need attention. Review the recommendations below.'**
  String get privacyScoreDescGood;

  /// No description provided for @privacyScoreDescPoor.
  ///
  /// In en, this message translates to:
  /// **'Several high-risk permissions are active. Take action now.'**
  String get privacyScoreDescPoor;

  /// No description provided for @privacyScoreDescCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical privacy exposure detected. Revoke sensitive permissions immediately.'**
  String get privacyScoreDescCritical;

  /// No description provided for @privacyBulletHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get privacyBulletHighRisk;

  /// No description provided for @privacyBulletMediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium risk'**
  String get privacyBulletMediumRisk;

  /// No description provided for @privacyBulletProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get privacyBulletProtected;

  /// No description provided for @privacySummaryHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get privacySummaryHighRisk;

  /// No description provided for @privacySummaryMediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get privacySummaryMediumRisk;

  /// No description provided for @privacyLowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get privacyLowRisk;

  /// No description provided for @privacyRiskBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Risk Breakdown'**
  String get privacyRiskBreakdownTitle;

  /// No description provided for @privacyNoPermissionData.
  ///
  /// In en, this message translates to:
  /// **'No permission data yet.'**
  String get privacyNoPermissionData;

  /// No description provided for @privacyLegendHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get privacyLegendHigh;

  /// No description provided for @privacyLegendMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get privacyLegendMedium;

  /// No description provided for @privacyExposureTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Exposure by Permission'**
  String get privacyExposureTitle;

  /// No description provided for @privacyAppsGrantedLabel.
  ///
  /// In en, this message translates to:
  /// **'# apps granted'**
  String get privacyAppsGrantedLabel;

  /// No description provided for @privacyRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get privacyRecommendationsTitle;

  /// No description provided for @privacyAppPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get privacyAppPermissionsTitle;

  /// No description provided for @privacyNoPermissionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No permissions match this filter.'**
  String get privacyNoPermissionsMatch;

  /// No description provided for @privacyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get privacyFilterAll;

  /// No description provided for @privacyFilterGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get privacyFilterGranted;

  /// No description provided for @privacyUsageTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Usage Timeline'**
  String get privacyUsageTimelineTitle;

  /// No description provided for @privacyProBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get privacyProBadge;

  /// No description provided for @privacyUsageTimelineDesc1.
  ///
  /// In en, this message translates to:
  /// **'Which apps with camera, microphone, or location access were recently open.'**
  String get privacyUsageTimelineDesc1;

  /// No description provided for @privacyUsageTimelineDesc2.
  ///
  /// In en, this message translates to:
  /// **'Based on foreground app time, not confirmed sensor access.'**
  String get privacyUsageTimelineDesc2;

  /// No description provided for @privacyUsageTimelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No apps with camera, microphone, or location access were open in the last 7 days.'**
  String get privacyUsageTimelineEmpty;

  /// No description provided for @privacyOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get privacyOpenSettings;

  /// No description provided for @privacyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get privacyRetry;

  /// No description provided for @privacyLoadUsageTimeline.
  ///
  /// In en, this message translates to:
  /// **'Load Usage Timeline'**
  String get privacyLoadUsageTimeline;

  /// No description provided for @privacyUsageAccessNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Usage Access isn\'t granted yet. Enable it for OptiSec in system settings, then tap Retry.'**
  String get privacyUsageAccessNotGranted;

  /// No description provided for @privacyUsageAccessExplain.
  ///
  /// In en, this message translates to:
  /// **'Requires \"Usage Access\" to be granted in system settings. This lets OptiSec see which apps were recently open — it does not grant access to any personal data.'**
  String get privacyUsageAccessExplain;

  /// No description provided for @privacyUsageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the usage timeline.'**
  String get privacyUsageLoadError;

  /// No description provided for @privacyWhatPermissionDoes.
  ///
  /// In en, this message translates to:
  /// **'What This Permission Does'**
  String get privacyWhatPermissionDoes;

  /// No description provided for @privacyRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get privacyRecommendationTitle;

  /// No description provided for @privacyOpenSettingsToRevoke.
  ///
  /// In en, this message translates to:
  /// **'Open Settings to Revoke'**
  String get privacyOpenSettingsToRevoke;

  /// No description provided for @privacyPermissionDeniedProtected.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied — You\'re Protected'**
  String get privacyPermissionDeniedProtected;

  /// No description provided for @privacyStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get privacyStatusLabel;

  /// No description provided for @privacyAppsLabel.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get privacyAppsLabel;

  /// No description provided for @privacyRiskLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get privacyRiskLevelLabel;

  /// No description provided for @privacyGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get privacyGranted;

  /// No description provided for @privacyDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get privacyDenied;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count} apps'**
  String privacyAppsCountChip(int count);

  /// No description provided for @privacyRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get privacyRevoke;

  /// No description provided for @privacyDeniedCheck.
  ///
  /// In en, this message translates to:
  /// **'Denied ✓'**
  String get privacyDeniedCheck;

  /// No description provided for @privacyNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get privacyNever;

  /// No description provided for @privacyJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get privacyJustNow;

  ///
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String privacyMinutesAgo(int minutes);

  ///
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String privacyHoursAgo(int hours);

  ///
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String privacyDaysAgo(int days);

  /// No description provided for @privacyOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get privacyOpenNow;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count}× / 7d'**
  String privacyTimesPerWeek(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'{name} Access Granted'**
  String privacyRecGrantedTitle(String name);

  /// No description provided for @privacyFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get privacyFix;

  /// No description provided for @privacyScanCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Scan Complete'**
  String get privacyScanCompleteTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Found {highRisk} high-risk and {mediumRisk} medium-risk permissions.'**
  String privacyScanCompleteBody(int highRisk, int mediumRisk);

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionScanning.
  ///
  /// In en, this message translates to:
  /// **'Security Scanning'**
  String get settingsSectionScanning;

  /// No description provided for @settingsSectionPrivacyLock.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Lock'**
  String get settingsSectionPrivacyLock;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  ///
  ///
  /// In en, this message translates to:
  /// **'v{version} (Build {build})'**
  String settingsVersionBuild(String version, String build);

  /// No description provided for @settingsAllSystemsProtected.
  ///
  /// In en, this message translates to:
  /// **'All systems protected'**
  String get settingsAllSystemsProtected;

  /// No description provided for @settingsFreePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan — enter a license key to unlock Pro'**
  String get settingsFreePlanSubtitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lifetime license · {label}'**
  String settingsLifetimeLicenseWithLabel(String label);

  /// No description provided for @settingsLifetimeLicense.
  ///
  /// In en, this message translates to:
  /// **'Lifetime license'**
  String get settingsLifetimeLicense;

  ///
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String settingsValidUntil(String date);

  /// No description provided for @settingsProActive.
  ///
  /// In en, this message translates to:
  /// **'OptiSec Pro — Active'**
  String get settingsProActive;

  /// No description provided for @settingsProInactive.
  ///
  /// In en, this message translates to:
  /// **'OptiSec Pro'**
  String get settingsProInactive;

  /// No description provided for @settingsProBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get settingsProBadge;

  /// No description provided for @settingsFreeBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get settingsFreeBadge;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display theme'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsAutoScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Scan'**
  String get settingsAutoScanTitle;

  /// No description provided for @settingsAutoScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Periodically scan for threats'**
  String get settingsAutoScanSubtitle;

  /// No description provided for @settingsScanIntervalTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Interval'**
  String get settingsScanIntervalTitle;

  /// No description provided for @settingsScanIntervalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How often to run auto scans'**
  String get settingsScanIntervalSubtitle;

  /// No description provided for @settingsEvilTwinAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin Alerts'**
  String get settingsEvilTwinAlertsTitle;

  /// No description provided for @settingsEvilTwinAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn when a rogue access point is detected'**
  String get settingsEvilTwinAlertsSubtitle;

  /// No description provided for @settingsVpnDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'VPN Detection'**
  String get settingsVpnDetectionTitle;

  /// No description provided for @settingsVpnDetectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect active VPN connections'**
  String get settingsVpnDetectionSubtitle;

  /// No description provided for @settingsScanIntervalPrompt.
  ///
  /// In en, this message translates to:
  /// **'How often should OptiSec scan for threats?'**
  String get settingsScanIntervalPrompt;

  ///
  ///
  /// In en, this message translates to:
  /// **'Every {minutes} minutes'**
  String settingsEveryMinutes(int minutes);

  /// No description provided for @settingsEveryHour.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get settingsEveryHour;

  /// No description provided for @settingsFreqHigh.
  ///
  /// In en, this message translates to:
  /// **'High frequency — more battery usage'**
  String get settingsFreqHigh;

  /// No description provided for @settingsFreqBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced — recommended'**
  String get settingsFreqBalanced;

  /// No description provided for @settingsFreqLow.
  ///
  /// In en, this message translates to:
  /// **'Low frequency — minimal battery usage'**
  String get settingsFreqLow;

  /// No description provided for @settingsPushNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifTitle;

  /// No description provided for @settingsPushNotifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow OptiSec to send notifications'**
  String get settingsPushNotifSubtitle;

  /// No description provided for @settingsThreatAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Threat Alerts'**
  String get settingsThreatAlertsTitle;

  /// No description provided for @settingsThreatAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Immediate alerts for detected threats'**
  String get settingsThreatAlertsSubtitle;

  /// No description provided for @settingsWeeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Security Report'**
  String get settingsWeeklyReportTitle;

  /// No description provided for @settingsWeeklyReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Summary of threats and scans each week'**
  String get settingsWeeklyReportSubtitle;

  /// No description provided for @settingsExportReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Security Report'**
  String get settingsExportReportTitle;

  /// No description provided for @settingsExportReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a PDF summary of your current security status'**
  String get settingsExportReportSubtitle;

  /// No description provided for @settingsExportReportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExportReportAction;

  /// No description provided for @settingsExportReportExportingAction.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get settingsExportReportExportingAction;

  /// No description provided for @settingsExportReportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get settingsExportReportFailedTitle;

  /// No description provided for @settingsExportReportFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the PDF report. Please try again.'**
  String get settingsExportReportFailedBody;

  /// No description provided for @settingsBiometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get settingsBiometricLockTitle;

  /// No description provided for @settingsBiometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require fingerprint or Face ID to open app'**
  String get settingsBiometricLockSubtitle;

  /// No description provided for @settingsAppLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get settingsAppLockTitle;

  /// No description provided for @settingsAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PIN or biometric protection for individual apps'**
  String get settingsAppLockSubtitle;

  /// No description provided for @settingsUsageAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get settingsUsageAnalyticsTitle;

  /// No description provided for @settingsUsageAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data to improve the app'**
  String get settingsUsageAnalyticsSubtitle;

  /// No description provided for @settingsRateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate OptiSec'**
  String get settingsRateAppTitle;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review on the App Store'**
  String get settingsRateAppSubtitle;

  /// No description provided for @settingsOpeningAppStore.
  ///
  /// In en, this message translates to:
  /// **'Opening App Store…'**
  String get settingsOpeningAppStore;

  /// No description provided for @settingsShareAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get settingsShareAppTitle;

  /// No description provided for @settingsShareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell your friends about OptiSec'**
  String get settingsShareAppSubtitle;

  /// No description provided for @settingsOpeningShareSheet.
  ///
  /// In en, this message translates to:
  /// **'Opening share sheet…'**
  String get settingsOpeningShareSheet;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsOpeningPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Opening Privacy Policy…'**
  String get settingsOpeningPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsOpeningTerms.
  ///
  /// In en, this message translates to:
  /// **'Opening Terms of Service…'**
  String get settingsOpeningTerms;

  ///
  ///
  /// In en, this message translates to:
  /// **'v{version} ({build})'**
  String settingsVersionShort(String version, String build);

  /// No description provided for @settingsClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Scan History'**
  String get settingsClearHistoryTitle;

  /// No description provided for @settingsClearHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all saved scan results'**
  String get settingsClearHistorySubtitle;

  /// No description provided for @settingsClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsClearAction;

  /// No description provided for @settingsResetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsResetAllTitle;

  /// No description provided for @settingsResetAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase everything and restore defaults'**
  String get settingsResetAllSubtitle;

  /// No description provided for @settingsResettingAction.
  ///
  /// In en, this message translates to:
  /// **'Resetting…'**
  String get settingsResettingAction;

  /// No description provided for @settingsResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetAction;

  /// No description provided for @settingsClearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Scan History?'**
  String get settingsClearHistoryConfirmTitle;

  /// No description provided for @settingsClearHistoryConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove all saved scan results. Your settings will not be affected.'**
  String get settingsClearHistoryConfirmBody;

  /// No description provided for @settingsResetAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data?'**
  String get settingsResetAllConfirmTitle;

  /// No description provided for @settingsResetAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will erase all scan history, threat records, and restore all settings to their defaults. This cannot be undone.'**
  String get settingsResetAllConfirmBody;

  /// No description provided for @settingsResetEverythingAction.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get settingsResetEverythingAction;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsHistoryClearedTitle.
  ///
  /// In en, this message translates to:
  /// **'History Cleared'**
  String get settingsHistoryClearedTitle;

  /// No description provided for @settingsHistoryClearedBody.
  ///
  /// In en, this message translates to:
  /// **'Scan history has been erased.'**
  String get settingsHistoryClearedBody;

  /// No description provided for @settingsDataResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Reset'**
  String get settingsDataResetTitle;

  /// No description provided for @settingsDataResetBody.
  ///
  /// In en, this message translates to:
  /// **'All settings and scan data have been cleared.'**
  String get settingsDataResetBody;

  /// No description provided for @threatIntelTitle.
  ///
  /// In en, this message translates to:
  /// **'Threat Intel'**
  String get threatIntelTitle;

  /// No description provided for @threatIntelEmpty.
  ///
  /// In en, this message translates to:
  /// **'No threat intel available'**
  String get threatIntelEmpty;

  ///
  ///
  /// In en, this message translates to:
  /// **'Feed updated {time}'**
  String threatIntelFeedUpdated(String time);

  /// No description provided for @threatIntelFeedNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Feed not yet loaded'**
  String get threatIntelFeedNotLoaded;

  /// No description provided for @threatIntelJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get threatIntelJustNow;

  ///
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String threatIntelMinutesAgo(int minutes);

  ///
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String threatIntelHoursAgo(int hours);

  ///
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String threatIntelDaysAgo(int days);

  /// No description provided for @threatIntelSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get threatIntelSeverityCritical;

  /// No description provided for @threatIntelSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get threatIntelSeverityHigh;

  /// No description provided for @threatIntelSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get threatIntelSeverityMedium;

  /// No description provided for @threatIntelSeverityLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get threatIntelSeverityLow;

  /// No description provided for @licenseKeyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter License Key'**
  String get licenseKeyScreenTitle;

  /// No description provided for @licenseKeyIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the license key you received by email after your OptiSec Pro purchase.'**
  String get licenseKeyIntro;

  /// No description provided for @licenseKeyActivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'License Activated'**
  String get licenseKeyActivatedTitle;

  /// No description provided for @licenseKeyActivatedBody.
  ///
  /// In en, this message translates to:
  /// **'OptiSec Pro is now unlocked on this device.'**
  String get licenseKeyActivatedBody;

  /// No description provided for @licenseKeyFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'License Key'**
  String get licenseKeyFieldLabel;

  /// No description provided for @licenseKeyPasteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get licenseKeyPasteTooltip;

  /// No description provided for @licenseKeyActivateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get licenseKeyActivateButton;

  /// No description provided for @licenseKeyErrorInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid license key.'**
  String get licenseKeyErrorInvalidFormat;

  /// No description provided for @licenseKeyErrorInvalidSignature.
  ///
  /// In en, this message translates to:
  /// **'This key is invalid or has been tampered with.'**
  String get licenseKeyErrorInvalidSignature;

  /// No description provided for @licenseKeyErrorMalformed.
  ///
  /// In en, this message translates to:
  /// **'This key is corrupted.'**
  String get licenseKeyErrorMalformed;

  /// No description provided for @licenseKeyErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'This license has expired.'**
  String get licenseKeyErrorExpired;

  ///
  ///
  /// In en, this message translates to:
  /// **'This license expired on {date}.'**
  String licenseKeyErrorExpiredOn(String date);

  /// No description provided for @licenseKeyErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error.'**
  String get licenseKeyErrorUnknown;

  /// No description provided for @paywallHaveLicenseKey.
  ///
  /// In en, this message translates to:
  /// **'Have a License Key?'**
  String get paywallHaveLicenseKey;

  /// No description provided for @navPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get navPrivacy;

  /// No description provided for @navAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get navAcademy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock \"{feature}\" with OptiSec Pro'**
  String paywallUnlockFeature(String feature);

  /// No description provided for @paywallBenefitEvilTwin.
  ///
  /// In en, this message translates to:
  /// **'Full Evil Twin analysis'**
  String get paywallBenefitEvilTwin;

  /// No description provided for @paywallBenefitPdfReports.
  ///
  /// In en, this message translates to:
  /// **'Weekly PDF reports'**
  String get paywallBenefitPdfReports;

  /// No description provided for @paywallBenefitAcademyLessons.
  ///
  /// In en, this message translates to:
  /// **'All Cyber Academy lessons'**
  String get paywallBenefitAcademyLessons;

  /// No description provided for @paywallBenefitPriorityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Priority alerts'**
  String get paywallBenefitPriorityAlerts;

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @paywallBestValueBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValueBadge;

  /// No description provided for @paywallContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallContinueButton;

  /// No description provided for @appLockBatteryWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization may stop App Lock'**
  String get appLockBatteryWarningTitle;

  /// No description provided for @appLockBatteryWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Allow unrestricted background activity so locked apps stay protected.'**
  String get appLockBatteryWarningBody;

  /// No description provided for @appLockSetPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get appLockSetPinLabel;

  /// No description provided for @pinSetupChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN'**
  String get pinSetupChooseTitle;

  /// No description provided for @pinSetupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinSetupConfirmTitle;

  /// No description provided for @pinSetupMismatchError.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinSetupMismatchError;

  /// No description provided for @pinSetupSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save PIN. Try again.'**
  String get pinSetupSaveError;

  /// No description provided for @appLockSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get appLockSearchHint;

  /// No description provided for @appLockNoAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get appLockNoAppsFound;

  /// No description provided for @appLockPinPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN to start locking apps'**
  String get appLockPinPromptTitle;

  /// No description provided for @appLockOverlayPermissionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Allow \"Display over other apps\" so the lock screen can appear'**
  String get appLockOverlayPermissionPrompt;

  /// No description provided for @appLockAllowButton.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get appLockAllowButton;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count} badges'**
  String cyberAcademyBadgesCount(int count);

  /// No description provided for @cyberAcademySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lessons, topics, tags…'**
  String get cyberAcademySearchHint;

  /// No description provided for @cyberAcademyFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get cyberAcademyFeaturedTitle;

  /// No description provided for @cyberAcademyContinueWhereLeftOff.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WHERE YOU LEFT OFF'**
  String get cyberAcademyContinueWhereLeftOff;

  /// No description provided for @cyberAcademyCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cyberAcademyCategoryAll;

  /// No description provided for @cyberAcademyCategoryPhishing.
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get cyberAcademyCategoryPhishing;

  /// No description provided for @cyberAcademyCategoryPassword.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get cyberAcademyCategoryPassword;

  /// No description provided for @cyberAcademyCategoryNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get cyberAcademyCategoryNetwork;

  /// No description provided for @cyberAcademySectionAllLessons.
  ///
  /// In en, this message translates to:
  /// **'All Lessons'**
  String get cyberAcademySectionAllLessons;

  /// No description provided for @cyberAcademySectionSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get cyberAcademySectionSearchResults;

  /// No description provided for @cyberAcademySectionPhishingLessons.
  ///
  /// In en, this message translates to:
  /// **'Phishing Lessons'**
  String get cyberAcademySectionPhishingLessons;

  /// No description provided for @cyberAcademySectionPasswordLessons.
  ///
  /// In en, this message translates to:
  /// **'Password Lessons'**
  String get cyberAcademySectionPasswordLessons;

  /// No description provided for @cyberAcademySectionNetworkLessons.
  ///
  /// In en, this message translates to:
  /// **'Network Lessons'**
  String get cyberAcademySectionNetworkLessons;

  /// No description provided for @cyberAcademySectionPrivacyLessons.
  ///
  /// In en, this message translates to:
  /// **'Privacy Lessons'**
  String get cyberAcademySectionPrivacyLessons;

  /// No description provided for @cyberAcademyNoLessonsFound.
  ///
  /// In en, this message translates to:
  /// **'No lessons found'**
  String get cyberAcademyNoLessonsFound;

  ///
  ///
  /// In en, this message translates to:
  /// **'for \"{query}\"'**
  String cyberAcademySearchResultsFor(String query);

  /// No description provided for @cyberAcademyBadgeContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get cyberAcademyBadgeContinue;

  /// No description provided for @cyberAcademyBadgeFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get cyberAcademyBadgeFeatured;

  ///
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String cyberAcademyPercentComplete(int percent);

  ///
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String cyberAcademyXpPoints(int xp);

  ///
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String cyberAcademyDurationMinutes(int minutes);

  /// No description provided for @cyberAcademyDifficultyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get cyberAcademyDifficultyBeginner;

  /// No description provided for @cyberAcademyDifficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get cyberAcademyDifficultyIntermediate;

  /// No description provided for @cyberAcademyDifficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get cyberAcademyDifficultyAdvanced;

  /// No description provided for @cyberAcademyContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get cyberAcademyContinueButton;

  /// No description provided for @cyberAcademyStartLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson →'**
  String get cyberAcademyStartLessonButton;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String cyberAcademyStepsCount(int count);

  /// No description provided for @cyberAcademyStatusDone.
  ///
  /// In en, this message translates to:
  /// **'✓ Done'**
  String get cyberAcademyStatusDone;

  /// No description provided for @cyberAcademyStatusStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get cyberAcademyStatusStart;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level {level} — Security Analyst'**
  String cyberAcademyLevelTitle(int level);

  ///
  ///
  /// In en, this message translates to:
  /// **'{xp} XP total'**
  String cyberAcademyXpTotal(int xp);

  ///
  ///
  /// In en, this message translates to:
  /// **'Progress to Level {level}'**
  String cyberAcademyProgressToLevel(int level);

  /// No description provided for @cyberAcademyCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get cyberAcademyCompletedLabel;

  /// No description provided for @cyberAcademyBadgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get cyberAcademyBadgesLabel;

  /// No description provided for @cyberAcademyStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get cyberAcademyStreakLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String cyberAcademyStreakDays(int days);

  ///
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String cyberAcademyStepCounter(int step, int total);

  /// No description provided for @cyberAcademyKnowledgeCheck.
  ///
  /// In en, this message translates to:
  /// **'KNOWLEDGE CHECK'**
  String get cyberAcademyKnowledgeCheck;

  /// No description provided for @cyberAcademyCorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Correct! Well done.'**
  String get cyberAcademyCorrectFeedback;

  /// No description provided for @cyberAcademyIncorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Not quite — the correct answer is highlighted above.'**
  String get cyberAcademyIncorrectFeedback;

  /// No description provided for @cyberAcademyCompleteLessonButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Lesson'**
  String get cyberAcademyCompleteLessonButton;

  /// No description provided for @cyberAcademyNextStepButton.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get cyberAcademyNextStepButton;

  /// No description provided for @cyberAcademyContentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content coming soon'**
  String get cyberAcademyContentComingSoon;

  /// No description provided for @cyberAcademyCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get cyberAcademyCloseButton;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Advanced Security Suite'**
  String get splashTagline;

  /// No description provided for @splashStatusInit.
  ///
  /// In en, this message translates to:
  /// **'Initializing security engine…'**
  String get splashStatusInit;

  /// No description provided for @splashStatusThreatDb.
  ///
  /// In en, this message translates to:
  /// **'Loading threat database…'**
  String get splashStatusThreatDb;

  /// No description provided for @splashStatusNetwork.
  ///
  /// In en, this message translates to:
  /// **'Checking network interfaces…'**
  String get splashStatusNetwork;

  /// No description provided for @splashStatusPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Calibrating privacy scanner…'**
  String get splashStatusPrivacy;

  /// No description provided for @splashStatusReady.
  ///
  /// In en, this message translates to:
  /// **'All systems ready'**
  String get splashStatusReady;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingGetStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStartedButton;

  /// No description provided for @onboardingFeatureRealtimeThreatDetection.
  ///
  /// In en, this message translates to:
  /// **'Real-time threat detection'**
  String get onboardingFeatureRealtimeThreatDetection;

  /// No description provided for @onboardingFeatureNetworkPrivacyProtection.
  ///
  /// In en, this message translates to:
  /// **'Network & privacy protection'**
  String get onboardingFeatureNetworkPrivacyProtection;

  /// No description provided for @onboardingFeatureCybersecurityEducation.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity education'**
  String get onboardingFeatureCybersecurityEducation;

  /// No description provided for @onboardingFeatureEvilTwinDetection.
  ///
  /// In en, this message translates to:
  /// **'Evil Twin detection'**
  String get onboardingFeatureEvilTwinDetection;

  /// No description provided for @onboardingFeatureSignalRiskAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Signal & risk analysis'**
  String get onboardingFeatureSignalRiskAnalysis;

  /// No description provided for @onboardingFeatureConnectedDeviceAudit.
  ///
  /// In en, this message translates to:
  /// **'Connected device audit'**
  String get onboardingFeatureConnectedDeviceAudit;

  /// No description provided for @onboardingFeaturePermissionAuditing.
  ///
  /// In en, this message translates to:
  /// **'Permission auditing'**
  String get onboardingFeaturePermissionAuditing;

  /// No description provided for @onboardingFeatureRiskScoringPerApp.
  ///
  /// In en, this message translates to:
  /// **'Risk scoring per app'**
  String get onboardingFeatureRiskScoringPerApp;

  /// No description provided for @onboardingFeatureOneTapPermissionRevoke.
  ///
  /// In en, this message translates to:
  /// **'One-tap permission revoke'**
  String get onboardingFeatureOneTapPermissionRevoke;

  /// No description provided for @onboardingFeatureHandsOnLessons.
  ///
  /// In en, this message translates to:
  /// **'8+ hands-on lessons'**
  String get onboardingFeatureHandsOnLessons;

  /// No description provided for @onboardingFeatureKnowledgeQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Knowledge quizzes'**
  String get onboardingFeatureKnowledgeQuizzes;

  /// No description provided for @onboardingFeatureXpLevelsBadges.
  ///
  /// In en, this message translates to:
  /// **'XP, levels & badges'**
  String get onboardingFeatureXpLevelsBadges;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
