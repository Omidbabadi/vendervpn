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
  /// **'Subscription Imported'**
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

  /// toggle dark/light theme
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get change_theme;

  /// next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// click on connect button without selecting a config
  ///
  /// In en, this message translates to:
  /// **'Please Select A Config First'**
  String get select_config;

  /// text for loading state title
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_title;

  /// text for loading state content
  ///
  /// In en, this message translates to:
  /// **'Please Wait a Moment'**
  String get loading_content;

  /// Connecting status text
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Idle status text
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// Error when configs fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed To Load Configs'**
  String get failed_to_load_configs;

  /// Server label
  ///
  /// In en, this message translates to:
  /// **'Server: '**
  String get server;

  /// IP label
  ///
  /// In en, this message translates to:
  /// **'IP: '**
  String get ip_label;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_nodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nav_nodes;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get nav_settings;

  /// No description provided for @session_duration.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get session_duration;

  /// No description provided for @node_latency_ms.
  ///
  /// In en, this message translates to:
  /// **'Node Latency (ms)'**
  String get node_latency_ms;

  /// No description provided for @available_nodes.
  ///
  /// In en, this message translates to:
  /// **'Available Nodes'**
  String get available_nodes;

  /// No description provided for @resolving_vpn_location.
  ///
  /// In en, this message translates to:
  /// **'Resolving VPN Location...'**
  String get resolving_vpn_location;

  /// No description provided for @connected_tunnel.
  ///
  /// In en, this message translates to:
  /// **'Connected Tunnel'**
  String get connected_tunnel;

  /// No description provided for @your_location_prefix.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get your_location_prefix;

  /// No description provided for @detecting_location.
  ///
  /// In en, this message translates to:
  /// **'Detecting Location...'**
  String get detecting_location;

  /// No description provided for @connected_ip_label.
  ///
  /// In en, this message translates to:
  /// **'Connected IP'**
  String get connected_ip_label;

  /// No description provided for @resolving_endpoint.
  ///
  /// In en, this message translates to:
  /// **'Resolving endpoint...'**
  String get resolving_endpoint;

  /// No description provided for @your_ip_label.
  ///
  /// In en, this message translates to:
  /// **'Your IP'**
  String get your_ip_label;

  /// No description provided for @resolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving...'**
  String get resolving;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @real_ip_label.
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get real_ip_label;

  /// No description provided for @connected_route_label.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected_route_label;

  /// No description provided for @target_node_label.
  ///
  /// In en, this message translates to:
  /// **'Target Node'**
  String get target_node_label;

  /// No description provided for @none_label.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none_label;

  /// No description provided for @switch_node.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switch_node;

  /// No description provided for @vpn_state_badge.
  ///
  /// In en, this message translates to:
  /// **'VPN State'**
  String get vpn_state_badge;

  /// No description provided for @establishing_tunnel.
  ///
  /// In en, this message translates to:
  /// **'Establishing Tunnel...'**
  String get establishing_tunnel;

  /// No description provided for @stay_until_ad_loads.
  ///
  /// In en, this message translates to:
  /// **'Please stay on this screen until the ad loads'**
  String get stay_until_ad_loads;

  /// No description provided for @local_nodes_btn.
  ///
  /// In en, this message translates to:
  /// **'Local Nodes'**
  String get local_nodes_btn;

  /// No description provided for @continue_to_home.
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get continue_to_home;

  /// No description provided for @preferences_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences_subtitle;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @theme_appearance.
  ///
  /// In en, this message translates to:
  /// **'Theme Appearance'**
  String get theme_appearance;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @app_language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get app_language;

  /// No description provided for @tunnel_endpoints_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Endpoints'**
  String get tunnel_endpoints_subtitle;

  /// No description provided for @nodes_title.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodes_title;

  /// No description provided for @ping_all.
  ///
  /// In en, this message translates to:
  /// **'Ping All'**
  String get ping_all;

  /// No description provided for @cloud_nodes_tab.
  ///
  /// In en, this message translates to:
  /// **'Cloud Nodes'**
  String get cloud_nodes_tab;

  /// No description provided for @local_nodes_tab.
  ///
  /// In en, this message translates to:
  /// **'Local Nodes'**
  String get local_nodes_tab;

  /// No description provided for @clipboard_action.
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get clipboard_action;

  /// No description provided for @qr_code_action.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qr_code_action;

  /// No description provided for @sub_url_action.
  ///
  /// In en, this message translates to:
  /// **'Sub URL'**
  String get sub_url_action;

  /// No description provided for @no_cloud_nodes.
  ///
  /// In en, this message translates to:
  /// **'No cloud nodes synced yet'**
  String get no_cloud_nodes;

  /// No description provided for @no_local_nodes.
  ///
  /// In en, this message translates to:
  /// **'No local nodes imported yet'**
  String get no_local_nodes;

  /// No description provided for @no_cloud_nodes_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the sync icon above to fetch Appwrite nodes'**
  String get no_cloud_nodes_hint;

  /// No description provided for @no_local_nodes_hint.
  ///
  /// In en, this message translates to:
  /// **'Import from Clipboard, QR Code, or Subscription URL'**
  String get no_local_nodes_hint;

  /// No description provided for @clipboard_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Clipboard Empty'**
  String get clipboard_empty_title;

  /// No description provided for @clipboard_empty_msg.
  ///
  /// In en, this message translates to:
  /// **'Copy a V2Ray link or subscription URL first.'**
  String get clipboard_empty_msg;

  /// No description provided for @nodes_imported_title.
  ///
  /// In en, this message translates to:
  /// **'Nodes Imported'**
  String get nodes_imported_title;

  /// No description provided for @nodes_imported_msg.
  ///
  /// In en, this message translates to:
  /// **'Added V2Ray node(s) from clipboard.'**
  String get nodes_imported_msg;

  /// No description provided for @invalid_format_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid Format'**
  String get invalid_format_title;

  /// No description provided for @invalid_format_msg.
  ///
  /// In en, this message translates to:
  /// **'No valid vmess://, vless://, trojan://, ss://, or hy2:// links found.'**
  String get invalid_format_msg;

  /// No description provided for @import_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get import_failed_title;

  /// No description provided for @add_subscription_url.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription URL'**
  String get add_subscription_url;

  /// No description provided for @auto_syncs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-syncs V2Ray configs on your chosen schedule'**
  String get auto_syncs_subtitle;

  /// No description provided for @subscription_name_label.
  ///
  /// In en, this message translates to:
  /// **'Subscription Name'**
  String get subscription_name_label;

  /// No description provided for @subscription_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Premium EU Nodes'**
  String get subscription_name_hint;

  /// No description provided for @subscription_url_label.
  ///
  /// In en, this message translates to:
  /// **'Subscription URL'**
  String get subscription_url_label;

  /// No description provided for @auto_update_interval.
  ///
  /// In en, this message translates to:
  /// **'Auto-Update Interval'**
  String get auto_update_interval;

  /// No description provided for @manual_interval.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual_interval;

  /// No description provided for @every_n_hours.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every_n_hours;

  /// No description provided for @save_and_fetch_configs.
  ///
  /// In en, this message translates to:
  /// **'Save & Fetch Configs'**
  String get save_and_fetch_configs;

  /// No description provided for @subscription_synced_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Synced'**
  String get subscription_synced_title;

  /// No description provided for @no_nodes_found_title.
  ///
  /// In en, this message translates to:
  /// **'No Nodes Found'**
  String get no_nodes_found_title;

  /// No description provided for @no_nodes_found_msg.
  ///
  /// In en, this message translates to:
  /// **'Could not parse any V2Ray nodes from that URL.'**
  String get no_nodes_found_msg;

  /// No description provided for @subscription_error_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Error'**
  String get subscription_error_title;

  /// No description provided for @qr_node_added_title.
  ///
  /// In en, this message translates to:
  /// **'QR Node Added'**
  String get qr_node_added_title;

  /// No description provided for @qr_node_added_msg.
  ///
  /// In en, this message translates to:
  /// **'Scanned & imported V2Ray node(s) into Local Nodes.'**
  String get qr_node_added_msg;

  /// No description provided for @invalid_qr_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalid_qr_title;

  /// No description provided for @invalid_qr_msg.
  ///
  /// In en, this message translates to:
  /// **'Scanned QR code did not contain a valid V2Ray URI or subscription.'**
  String get invalid_qr_msg;

  /// No description provided for @qr_scan_error_title.
  ///
  /// In en, this message translates to:
  /// **'QR Scan Error'**
  String get qr_scan_error_title;

  /// No description provided for @scan_v2ray_qr_title.
  ///
  /// In en, this message translates to:
  /// **'Scan V2Ray QR Code'**
  String get scan_v2ray_qr_title;

  /// No description provided for @scan_v2ray_qr_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Point camera at a vmess, vless, trojan, ss, or sub QR'**
  String get scan_v2ray_qr_subtitle;

  /// No description provided for @direct_imports.
  ///
  /// In en, this message translates to:
  /// **'Direct Imports'**
  String get direct_imports;

  /// No description provided for @subscription_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Updated'**
  String get subscription_updated_title;

  /// No description provided for @sync_failed_title.
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get sync_failed_title;

  /// No description provided for @subscription_removed_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription Removed'**
  String get subscription_removed_title;

  /// No description provided for @no_nodes_in_sub.
  ///
  /// In en, this message translates to:
  /// **'No nodes in this subscription. Tap refresh to sync.'**
  String get no_nodes_in_sub;

  /// No description provided for @tunnel_active_title.
  ///
  /// In en, this message translates to:
  /// **'Tunnel Active'**
  String get tunnel_active_title;

  /// No description provided for @tunnel_active_msg.
  ///
  /// In en, this message translates to:
  /// **'Disconnect current session before switching nodes.'**
  String get tunnel_active_msg;
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
