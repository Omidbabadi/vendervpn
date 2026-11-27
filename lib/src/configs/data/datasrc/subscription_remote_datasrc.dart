import 'dart:convert';
import 'dart:io';

import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/core/utils/subscription_info_parser.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';

/// Downloads subscription URLs.
abstract class SubscriptionRemoteDatasrc {
  const SubscriptionRemoteDatasrc();

  /// The links at [url], plus the account info from the
  /// `Subscription-Userinfo` / `Announce` headers or an `#announce:` line.
  /// Throws [ServerException] when the URL is invalid or the request fails.
  Future<SubscriptionFetch> fetchSubscription(String url);

  /// Only the account info, from a `HEAD` request (`GET` as a fallback).
  /// null when the provider reports none or the request fails.
  Future<SubscriptionUserInfo?> fetchUserInfo(String url);
}

class SubscriptionRemoteDatasrcImpl implements SubscriptionRemoteDatasrc {
  const SubscriptionRemoteDatasrcImpl();

  static const _userAgent = 'VenderVPN/1.0 (v2rayNG; Flutter)';
  static const _fallbackUserAgent =
      'VenderVPN/1.0 (v2rayNG; clash.meta; Flutter)';

  @override
  Future<SubscriptionUserInfo?> fetchUserInfo(String url) async {
    final uri = _httpUri(url);
    if (uri == null) return null;

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.headUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close();
      await response.drain<void>();
      final info = _infoFromHeaders(response.headers);
      if (info != null) return info;

      // Some servers only send the headers on GET.
      final getReq = await client.getUrl(uri);
      getReq.headers.set(HttpHeaders.userAgentHeader, _fallbackUserAgent);
      final getRes = await getReq.close();
      await getRes.drain<void>();
      return _infoFromHeaders(getRes.headers);
    } catch (e) {
      appLog('Failed to fetch subscription userinfo: $e');
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Future<SubscriptionFetch> fetchSubscription(String url) async {
    final uri = _httpUri(url);
    if (uri == null) {
      throw const ServerException(
        message: 'Invalid subscription URL',
        statusCode: 400,
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          message: 'Subscription returned HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      var userInfo = _infoFromHeaders(response.headers);
      final body = await response.transform(utf8.decoder).join();
      final links = V2rayImportHelper.extractLinksFromPayload(body);

      // GET had no `Subscription-Userinfo` or `Announce`: try HEAD.
      if (userInfo == null || !userInfo.hasAnnounce) {
        try {
          final headReq = await client.headUrl(uri);
          headReq.headers.set(HttpHeaders.userAgentHeader, _fallbackUserAgent);
          final headRes = await headReq.close();
          await headRes.drain<void>();
          final headInfo = _infoFromHeaders(headRes.headers);
          if (userInfo == null) {
            userInfo = headInfo;
          } else if (headInfo != null) {
            userInfo = userInfo.copyWith(
              announce: userInfo.announce ?? headInfo.announce,
            );
          }
        } catch (_) {}
      }

      // Still no announcement: look for `#announce:` in the body.
      if (userInfo == null || !userInfo.hasAnnounce) {
        final bodyAnnounce = SubscriptionInfoParser.announceFromBody(body);
        if (bodyAnnounce != null) {
          userInfo =
              userInfo != null
                  ? userInfo.copyWith(announce: bodyAnnounce)
                  : SubscriptionUserInfo(
                    upload: 0,
                    download: 0,
                    total: 0,
                    expire: 0,
                    announce: bodyAnnounce,
                    hasTrafficData: false,
                  );
        }
      }

      return (links: links, userInfo: userInfo);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Fetching the subscription failed: $e',
        statusCode: 500,
      );
    } finally {
      client.close();
    }
  }

  static Uri? _httpUri(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null;
    }
    return uri;
  }

  /// `Subscription-Userinfo` and `Announce` from [headers], case-insensitive.
  static SubscriptionUserInfo? _infoFromHeaders(HttpHeaders headers) {
    String? rawUserInfo = headers.value('subscription-userinfo');
    String? rawAnnounce =
        headers.value('announce') ?? headers.value('x-announce');

    headers.forEach((name, values) {
      if (values.isEmpty) return;
      final lower = name.toLowerCase();
      if (rawUserInfo == null && lower == 'subscription-userinfo') {
        rawUserInfo = values.join('; ');
      } else if (rawAnnounce == null &&
          (lower == 'announce' || lower == 'x-announce')) {
        rawAnnounce = values.join('\n');
      }
    });

    return SubscriptionInfoParser.parseHeader(
      rawUserInfo,
      rawAnnounce: rawAnnounce,
    );
  }
}
