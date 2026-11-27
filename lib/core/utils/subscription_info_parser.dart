import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';

/// Reads the account info subscription providers send in the
/// `Subscription-Userinfo` / `Announce` headers or an `#announce:` line.
class SubscriptionInfoParser {
  const SubscriptionInfoParser._();

  /// Parses an `Announce` header or comment value such as
  /// `base64:2YTYt9mB2Kcg...` or plain text.
  static String? parseAnnounce(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;
    var cleaned = rawValue.trim();

    if (cleaned.toLowerCase().startsWith('announce:')) {
      cleaned = cleaned.substring('announce:'.length).trim();
    } else if (cleaned.toLowerCase().startsWith('#announce:')) {
      cleaned = cleaned.substring('#announce:'.length).trim();
    }

    if (cleaned.toLowerCase().startsWith('base64:')) {
      final b64Payload = cleaned.substring('base64:'.length).trim();
      final decoded = V2rayImportHelper.tryDecodeBase64String(b64Payload);
      if (decoded != null && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    }

    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// Parses a `Subscription-Userinfo` header string such as
  /// `upload=65973995349; download=832599811771; total=0; expire=0`.
  /// null when neither the header nor [rawAnnounce] carries anything.
  static SubscriptionUserInfo? parseHeader(
    String? rawHeader, {
    String? rawAnnounce,
  }) {
    final parsedAnnounce = parseAnnounce(rawAnnounce);

    int? upload;
    int? download;
    int? total;
    int? expire;

    if (rawHeader != null && rawHeader.trim().isNotEmpty) {
      var cleaned = rawHeader.trim();
      final colonIdx = cleaned.indexOf(':');
      if (colonIdx != -1 &&
          cleaned.substring(0, colonIdx).toLowerCase().contains('userinfo')) {
        cleaned = cleaned.substring(colonIdx + 1).trim();
      }

      final parts = cleaned.split(RegExp(r'[;,]'));
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length != 2) continue;
        final key = kv[0].trim().toLowerCase();
        final valStr = kv[1].trim();
        final val = int.tryParse(valStr) ?? double.tryParse(valStr)?.round();
        if (val == null) continue;
        switch (key) {
          case 'upload':
            upload = val;
          case 'download':
            download = val;
          case 'total':
            total = val;
          case 'expire':
            expire = val;
        }
      }
    }

    final hasTraffic =
        upload != null || download != null || total != null || expire != null;

    if (!hasTraffic && parsedAnnounce == null) {
      return null;
    }

    return SubscriptionUserInfo(
      upload: upload ?? 0,
      download: download ?? 0,
      total: total ?? 0,
      expire: expire ?? 0,
      announce: parsedAnnounce,
      hasTrafficData: hasTraffic,
    );
  }

  /// The `#announce:` line of a raw or base64-encoded subscription body.
  static String? announceFromBody(String rawBody) {
    final trimmed = rawBody.trim();
    if (trimmed.isEmpty) return null;

    String? scanLines(String text) {
      for (final line in text.split(RegExp(r'[\r\n]+'))) {
        final l = line.trim();
        if (l.toLowerCase().startsWith('#announce:') ||
            l.toLowerCase().startsWith('announce:')) {
          return parseAnnounce(l);
        }
      }
      return null;
    }

    final direct = scanLines(trimmed);
    if (direct != null) return direct;

    final decoded = V2rayImportHelper.tryDecodeBase64String(trimmed);
    if (decoded != null) {
      return scanLines(decoded);
    }
    return null;
  }
}
