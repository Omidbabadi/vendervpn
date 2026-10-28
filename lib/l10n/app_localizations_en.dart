// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Change Language';

  @override
  String get change_language_title => 'Please Choose Your Preferred Language';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get permission => 'Permission Denied';

  @override
  String get connect => 'CONNECT';

  @override
  String get serverdelay => 'Server Delay';

  @override
  String get wait => 'Wait...';

  @override
  String get import_from_clipboard => 'Import from clipboard';

  @override
  String get import_from_qrcode => 'Import from qrcode';

  @override
  String get vpnstatus => 'VPN Status :';

  @override
  String get vpnstatus_connect => 'CONNECTED';

  @override
  String get vpnstatus_not_connect => 'NOT CONNECTED';

  @override
  String get traffic_information => 'Traffic Information :';

  @override
  String get speed => 'Speed :';

  @override
  String get traffic => 'Traffic :';

  @override
  String get actions => 'Actions :';

  @override
  String get disconnect => 'DISCONNECT';

  @override
  String get ping => 'ping';

  @override
  String get error => 'Error';

  @override
  String get succesful => 'Successful';

  @override
  String get delete_config_content =>
      'Config Will Remove Permanently, Are You Sure ?';

  @override
  String get delete => 'Delete';

  @override
  String get delete_selected_config => 'Could not delete this config';

  @override
  String get remove => 'Removed';

  @override
  String get import_sub => 'Subscription Imported';

  @override
  String get import_sub_link => 'Import From Subscription ';

  @override
  String get subscription_settings => 'Subscription Group Settings ';

  @override
  String get no_subscription_found => 'Nothing to show ';

  @override
  String get update_subscription => 'Update Subscriptions';

  @override
  String get server_issue => 'Server Issue';

  @override
  String get get_servers => 'fetch servers';

  @override
  String get founded_servers => 'Servers Found';

  @override
  String get change_theme => 'Toggle theme';

  @override
  String get next => 'Next';

  @override
  String get select_config => 'Please Select A Config First';

  @override
  String get loading_title => 'Loading...';

  @override
  String get loading_content => 'Please Wait a Moment';

  @override
  String get connecting => 'Connecting...';

  @override
  String get idle => 'Idle';

  @override
  String get failed_to_load_configs => 'Failed To Load Configs';

  @override
  String get server => 'Server: ';

  @override
  String get ip_label => 'IP: ';

  @override
  String get retry => 'Retry';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_nodes => 'Nodes';

  @override
  String get nav_settings => 'Setting';

  @override
  String get session_duration => 'Session Duration';

  @override
  String get node_latency_ms => 'Node Latency (ms)';

  @override
  String get available_nodes => 'Available Nodes';

  @override
  String get resolving_vpn_location => 'Resolving VPN Location...';

  @override
  String get connected_tunnel => 'Connected Tunnel';

  @override
  String get your_location_prefix => 'Your Location';

  @override
  String get detecting_location => 'Detecting Location...';

  @override
  String get connected_ip_label => 'Connected IP';

  @override
  String get resolving_endpoint => 'Resolving endpoint...';

  @override
  String get your_ip_label => 'Your IP';

  @override
  String get resolving => 'Resolving...';

  @override
  String get unknown => 'Unknown';

  @override
  String get real_ip_label => 'Real';

  @override
  String get connected_route_label => 'Connected';

  @override
  String get target_node_label => 'Target Node';

  @override
  String get none_label => 'None';

  @override
  String get switch_node => 'Switch';

  @override
  String get vpn_state_badge => 'VPN State';

  @override
  String get establishing_tunnel => 'Establishing Tunnel...';

  @override
  String get stay_until_ad_loads =>
      'Please stay on this screen until the ad loads';

  @override
  String get local_nodes_btn => 'Local Nodes';

  @override
  String get continue_to_home => 'Continue to Home';

  @override
  String get preferences_subtitle => 'Preferences';

  @override
  String get settings_title => 'Settings';

  @override
  String get theme_appearance => 'Theme Appearance';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get theme_system => 'System';

  @override
  String get app_language => 'App Language';

  @override
  String get tunnel_endpoints_subtitle => 'Tunnel Endpoints';

  @override
  String get nodes_title => 'Nodes';

  @override
  String get ping_all => 'Ping All';

  @override
  String get cloud_nodes_tab => 'Cloud Nodes';

  @override
  String get local_nodes_tab => 'Local Nodes';

  @override
  String get clipboard_action => 'Clipboard';

  @override
  String get qr_code_action => 'QR Code';

  @override
  String get sub_url_action => 'Sub URL';

  @override
  String get no_cloud_nodes => 'No cloud nodes synced yet';

  @override
  String get no_local_nodes => 'No local nodes imported yet';

  @override
  String get no_cloud_nodes_hint =>
      'Tap the sync icon above to fetch Appwrite nodes';

  @override
  String get no_local_nodes_hint =>
      'Import from Clipboard, QR Code, or Subscription URL';

  @override
  String get clipboard_empty_title => 'Clipboard Empty';

  @override
  String get clipboard_empty_msg =>
      'Copy a V2Ray link or subscription URL first.';

  @override
  String get nodes_imported_title => 'Nodes Imported';

  @override
  String get nodes_imported_msg => 'Added V2Ray node(s) from clipboard.';

  @override
  String get invalid_format_title => 'Invalid Format';

  @override
  String get invalid_format_msg =>
      'No valid vmess://, vless://, trojan://, ss://, or hy2:// links found.';

  @override
  String get import_failed_title => 'Import Failed';

  @override
  String get add_subscription_url => 'Add Subscription URL';

  @override
  String get auto_syncs_subtitle =>
      'Auto-syncs V2Ray configs on your chosen schedule';

  @override
  String get subscription_name_label => 'Subscription Name';

  @override
  String get subscription_name_hint => 'e.g. Premium EU Nodes';

  @override
  String get subscription_url_label => 'Subscription URL';

  @override
  String get auto_update_interval => 'Auto-Update Interval';

  @override
  String get manual_interval => 'Manual';

  @override
  String get every_n_hours => 'Every';

  @override
  String get save_and_fetch_configs => 'Save & Fetch Configs';

  @override
  String get subscription_synced_title => 'Subscription Synced';

  @override
  String get no_nodes_found_title => 'No Nodes Found';

  @override
  String get no_nodes_found_msg =>
      'Could not parse any V2Ray nodes from that URL.';

  @override
  String get subscription_error_title => 'Subscription Error';

  @override
  String get qr_node_added_title => 'QR Node Added';

  @override
  String get qr_node_added_msg =>
      'Scanned & imported V2Ray node(s) into Local Nodes.';

  @override
  String get invalid_qr_title => 'Invalid QR Code';

  @override
  String get invalid_qr_msg =>
      'Scanned QR code did not contain a valid V2Ray URI or subscription.';

  @override
  String get qr_scan_error_title => 'QR Scan Error';

  @override
  String get scan_v2ray_qr_title => 'Scan V2Ray QR Code';

  @override
  String get scan_v2ray_qr_subtitle =>
      'Point camera at a vmess, vless, trojan, ss, or sub QR';

  @override
  String get direct_imports => 'Direct Imports';

  @override
  String get subscription_updated_title => 'Subscription Updated';

  @override
  String get sync_failed_title => 'Sync Failed';

  @override
  String get subscription_removed_title => 'Subscription Removed';

  @override
  String get no_nodes_in_sub =>
      'No nodes in this subscription. Tap refresh to sync.';

  @override
  String get tunnel_active_title => 'Tunnel Active';

  @override
  String get tunnel_active_msg =>
      'Disconnect current session before switching nodes.';
}
