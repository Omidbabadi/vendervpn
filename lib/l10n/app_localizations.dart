import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('fa'),
  ];

  /// The current Language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get language;

  /// Change current Language
  ///
  /// In en, this message translates to:
  /// **'Please Choose Your Preferred Language'**
  String get change_language_title;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Change current Language
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Vpn Permission Denied
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permission;

  /// Start VPN Service
  ///
  /// In en, this message translates to:
  /// **'CONNECT'**
  String get connect;

  /// Get Ping Of The Selected Config
  ///
  /// In en, this message translates to:
  /// **'Server Delay'**
  String get serverdelay;

  /// Wait Until Server Delay Completed
  ///
  /// In en, this message translates to:
  /// **'Wait...'**
  String get wait;

  /// Import Configs From Clipboard
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get import_from_clipboard;

  /// Import Configs From Qrcode
  ///
  /// In en, this message translates to:
  /// **'Import from qrcode'**
  String get import_from_qrcode;

  /// Show Connection State
  ///
  /// In en, this message translates to:
  /// **'VPN Status :'**
  String get vpnstatus;

  /// Connection State Connected
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get vpnstatus_connect;

  /// Connection State Not Connected
  ///
  /// In en, this message translates to:
  /// **'NOT CONNECTED'**
  String get vpnstatus_not_connect;

  /// Show Connection Details
  ///
  /// In en, this message translates to:
  /// **'Traffic Information :'**
  String get traffic_information;

  /// Show Connection Speed
  ///
  /// In en, this message translates to:
  /// **'Speed :'**
  String get speed;

  /// Show Connection Usage
  ///
  /// In en, this message translates to:
  /// **'Traffic :'**
  String get traffic;

  /// Show Connection Usage
  ///
  /// In en, this message translates to:
  /// **'Actions :'**
  String get actions;

  /// Stop VPN Service
  ///
  /// In en, this message translates to:
  /// **'DISCONNECT'**
  String get disconnect;

  /// Ping Title
  ///
  /// In en, this message translates to:
  /// **'ping'**
  String get ping;

  /// Error Title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Successful Title
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get succesful;

  /// content for delete a config
  ///
  /// In en, this message translates to:
  /// **'Config Will Remove Permanently, Are You Sure ?'**
  String get delete_config_content;

  /// delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// cant delete selected config
  ///
  /// In en, this message translates to:
  /// **'Could not delete this config'**
  String get delete_selected_config;

  /// remove config
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get remove;

  /// import configs from subs
  ///
  /// In en, this message translates to:
  /// **'Subcription Imported'**
  String get import_sub;

  /// imported configs from subs successful
  ///
  /// In en, this message translates to:
  /// **'Import From Subscription '**
  String get import_sub_link;

  /// import configs from subs successful
  ///
  /// In en, this message translates to:
  /// **'Subscription Group Settings '**
  String get subscription_settings;

  /// There is No Subscription Link
  ///
  /// In en, this message translates to:
  /// **'Nothing to show '**
  String get no_subscription_found;

  /// Update Subscriptions
  ///
  /// In en, this message translates to:
  /// **'Update Subscriptions'**
  String get update_subscription;

  /// Future Is Not Implanted Yet
  ///
  /// In en, this message translates to:
  /// **'Future Is Not Implanted Yet '**
  String get coming_soon;

  /// Server Issue
  ///
  /// In en, this message translates to:
  /// **'Server Issue'**
  String get server_issue;

  /// get servers from backend
  ///
  /// In en, this message translates to:
  /// **'fetch servers'**
  String get get_servers;

  /// numbers of server from server
  ///
  /// In en, this message translates to:
  /// **'Servers Found'**
  String get founded_servers;

  /// Forbidden
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get change_theme;

  /// next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden Action'**
  String get forbidden;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
