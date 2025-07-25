import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:hive/hive.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/services/api_service.dart';
import 'package:vendervpn/services/v2ray_service.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class V2rayController extends AsyncNotifier<V2rayService> {
  @override
  Future<V2rayService> build() async {
    final service = await V2rayService.create();

    ref.onDispose(service.dispose);
    return service;
  }

  Future<void> getConfigsFromServer() async {
    final Box<ConfigModel> configsBox = Hive.box('configs');

    final apiService = ApiService();
    try {
      final configs = await apiService.getConfigsList();
      if (configs == null) return;
      ref.read(userPrefsProvider.notifier).setDefaultConfig(configs[0]);
      await configsBox.clear();
      await configsBox.addAll(configs);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> connect({required ConfigModel config}) async {
    //state = AsyncLoading();
    final adService = ref.read(adManagerProvier.notifier);
    final adState = ref.watch(adManagerProvier);
    final ConfigModel connectWith = ConfigModel(
      configjson: config.configjson,
      remark: config.remark,
      port: config.port,
      address: config.address,
      uri: config.uri,
      importedFrom: config.importedFrom,
      id: config.id,
      dateAdded: config.dateAdded,
    );

    try {
      await state.requireValue.connect(
        config: connectWith.configjson,
        remark: connectWith.remark,
        proxyOnly: false,
        bypassSubnets: [],
      );
      state = AsyncData(state.requireValue);
      if (!adState.initialized) {
        await adService.initUnityAds();
      }
      if (!adState.interstitialLoaded) {
        await adService.loadInterstitial();
      }
      await adService.showIntAd();
      if (!adState.adCompleted) {
        debugPrint('ad not completed');
      }
    } catch (e, st) {
      debugPrint(e.toString());
      state = AsyncError(e, st);
    }
  }

  Future<void> disconnect() async {
    try {
      state.requireValue.disconnect();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<int?> getDelay({String? config}) async {
    final loading = ref.read(getDelayProvider.notifier);
    loading.state = true;
    try {
      final ping = await state.requireValue.getDelay(config: config);

      return ping;
    } catch (_) {
      return null;
    } finally {
      loading.state = false;
    }
  }

  ValueNotifier<V2RayStatus> get status => state.requireValue.status;

  String? get coreVersion => state.requireValue.coreVersion;

  Future importFromClipboard() async {
    if (!await Clipboard.hasStrings()) {
      return null;
    }
    try {
      final String link =
          (await Clipboard.getData('text/plain'))?.text?.trim() ?? '';
      final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);
      //v2rayURL.dns = dnsServers;

      final config = ConfigModel(
        importedFrom: 'c',
        id: const Uuid().v4(),
        configjson: v2rayURL.getFullConfiguration(),
        remark: v2rayURL.remark,
        port: v2rayURL.port,
        address: v2rayURL.address,
        uri: v2rayURL.url,
        dateAdded: DateTime.now().toIso8601String(),
      );

      //    ref.read(selecedConfigProvider.notifier).changeConnectedConfig(config);
      ref.read(configsListProvider.notifier).addConfig(config);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> importFromSubcrtion(String subLink) async {
    if (!await Clipboard.hasStrings()) {
      return;
    }
    try {
      final response = await http.get(Uri.parse(subLink));
      final decodedResponse = base64.decode(response.body);
      final configsFromSubList = String.fromCharCodes(
        decodedResponse,
      ).split('\n');
      for (final config in configsFromSubList) {
        if (config == '') {
          return;
        }
        final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(config);
        final save = ConfigModel(
          configjson: v2rayURL.getFullConfiguration(),
          importedFrom: subLink,
          remark: v2rayURL.remark,
          port: v2rayURL.port,
          address: v2rayURL.address,
          uri: config,
          dateAdded: DateTime.now().toIso8601String(),
        );

        ref.read(configsListProvider.notifier).addConfig(save);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
  }
}
