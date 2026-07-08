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
