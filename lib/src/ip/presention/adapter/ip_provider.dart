import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/ip/data/datasrc/ip_remote_datasrc.dart';
import 'package:vendervpn/src/ip/domain/entities/ip_info.dart';

class IpSessionState {
  const IpSessionState({
    this.beforeTun,
    this.afterTun,
    this.isLoading = false,
  });

  final IpInfo? beforeTun;
  final IpInfo? afterTun;
  final bool isLoading;

  IpInfo? activeInfo(bool isConnected) =>
      isConnected ? afterTun : beforeTun;

  IpSessionState copyWith({
    IpInfo? beforeTun,
    IpInfo? afterTun,
    bool clearAfterTun = false,
    bool? isLoading,
  }) {
    return IpSessionState(
      beforeTun: beforeTun ?? this.beforeTun,
      afterTun: clearAfterTun ? null : (afterTun ?? this.afterTun),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final ipSessionProvider =
    NotifierProvider<IpSessionNotifier, IpSessionState>(IpSessionNotifier.new);

class IpSessionNotifier extends Notifier<IpSessionState> {
  final _datasrc = sl<IpRemoteDatasrc>();
  final _cacheHelper = sl<CacheHelper>();

  @override
  IpSessionState build() {
    Future.microtask(lookupBeforeTun);
    return const IpSessionState(isLoading: true);
  }

  /// Looks up the user's real IP and country BEFORE TUN is activated (or after disconnect).
  Future<void> lookupBeforeTun() async {
    state = state.copyWith(isLoading: true);
    try {
      final info = await _datasrc.fetchIpInfo(isTunnel: false);
      if (!ref.mounted) return;
      state = state.copyWith(beforeTun: info, isLoading: false);
    } catch (e) {
      debugPrint('lookupBeforeTun failed: $e');
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Looks up the connected tunnel exit IP and country AFTER TUN is activated.
  Future<void> lookupAfterTun(Config activeConfig) async {
    state = state.copyWith(clearAfterTun: true, isLoading: true);
    try {
      // Allow the V2Ray core & local HTTP proxy inbound (`127.0.0.1:10809`) to start listening
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final httpPort = _extractHttpInboundPort(activeConfig.configjson);

      IpInfo? info;
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          info = await _datasrc.fetchIpInfo(
            localHttpProxyPort: httpPort,
            isTunnel: true,
          );
          if (state.beforeTun == null || info.ip != state.beforeTun!.ip) {
            break;
          }
        } catch (e) {
          debugPrint('lookupAfterTun attempt ${attempt + 1} failed: $e');
        }
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }

      if (info == null) {
        if (ref.mounted) {
          state = state.copyWith(isLoading: false);
        }
        return;
      }

      if (!ref.mounted) return;

      await _cacheHelper.cacheIpCountry(activeConfig.address, info.countryCode);
      await _cacheHelper.cacheIpCountry(info.ip, info.countryCode);

      // Update the active Config with the verified tunnel exit IP & Country Code
      final updatedConfig = activeConfig.copyWith(
        country: info.countryCode,
        serverIp: info.ip,
      );
      await ref
          .read(currentConfigProvider.notifier)
          .setCurrentConfig(updatedConfig);

      // Also update in cloud/local lists so node tiles display the resolved country flag & endpoint IP
      final cloudList = ref.read(currentConfigsListProvider);
      if (cloudList.any((c) => c.id == activeConfig.id)) {
        ref.read(currentConfigsListProvider.notifier).setConfigs([
          for (final c in cloudList)
            if (c.id == activeConfig.id) updatedConfig else c,
        ]);
      } else {
        final localList = ref.read(localConfigsListProvider);
        if (localList.any((c) => c.id == activeConfig.id)) {
          await ref
              .read(localConfigsListProvider.notifier)
              .updateConfigEndpoint(
                activeConfig.id,
                serverIp: info.ip,
                countryCode: info.countryCode,
              );
        }
      }

      state = state.copyWith(afterTun: info, isLoading: false);
    } catch (e) {
      debugPrint('lookupAfterTun failed: $e');
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Called when TUN is deactivated so we clear the tunnel IP and re-verify the user's real IP.
  Future<void> onTunDisconnected() async {
    state = state.copyWith(clearAfterTun: true, isLoading: true);
    await lookupBeforeTun();
  }

  int? _extractHttpInboundPort(String configJson) {
    try {
      final decoded = jsonDecode(configJson) as Map<String, dynamic>;
      final inbounds = decoded['inbounds'] as List<dynamic>?;
      if (inbounds != null) {
        for (final item in inbounds) {
          if (item is Map<String, dynamic> &&
              item['protocol'] == 'http' &&
              item['port'] is int) {
            return item['port'] as int;
          }
        }
      }
    } catch (_) {}
    return 10809;
  }
}
