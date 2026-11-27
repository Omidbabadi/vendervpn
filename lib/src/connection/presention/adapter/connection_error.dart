import 'package:vendervpn/l10n/app_localizations.dart';

/// Why a connection attempt failed. The adapter reports a code and the UI
/// picks the text, so the adapter holds no user-facing strings.
enum ConnectionErrorCode {
  /// The quota server couldn't be reached and there's no snapshot from today.
  quotaUnavailable,

  /// The rewarded ad wasn't watched to the end.
  adNotCompleted,

  /// The server's daily ad bonus cap is reached.
  rewardCapReached,

  /// The server has the ad bonus turned off.
  rewardDisabled,

  /// The ad bonus request failed (network or server error).
  rewardFailed,

  /// The VPN engine couldn't start the tunnel.
  connectFailed,
}

/// Text for [code], or null when there's nothing more specific to say than
/// the generic error. [detail] is the engine's own message, if any.
String? connectionErrorText(
  AppLocalizations l10n,
  ConnectionErrorCode code, {
  String? detail,
}) {
  return switch (code) {
    ConnectionErrorCode.quotaUnavailable =>
      l10n.connection_error_quota_unavailable,
    ConnectionErrorCode.adNotCompleted => l10n.connection_error_ad_not_completed,
    ConnectionErrorCode.rewardCapReached => l10n.reward_error_cap_reached,
    ConnectionErrorCode.rewardDisabled => l10n.reward_error_disabled,
    ConnectionErrorCode.rewardFailed => l10n.reward_error_failed,
    ConnectionErrorCode.connectFailed =>
      (detail == null || detail.isEmpty) ? null : detail,
  };
}
