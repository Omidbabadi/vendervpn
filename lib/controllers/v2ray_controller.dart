import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/services/v2ray_service.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

final Map<String, dynamic> dnsServers = {
  "hosts": {
    "domain:googleapis.cn": "googleapis.com",
    "dns.alidns.com": [
      "223.5.5.5",
      "223.6.6.6",
      "2400:3200::1",
      "2400:3200:baba::1",
    ],
    "one.one.one.one": [
      "1.1.1.1",
      "1.0.0.1",
      "2606:4700:4700::1111",
      "2606:4700:4700::1001",
    ],
    "dot.pub": ["1.12.12.12", "120.53.53.53"],
    "dns.google": [
      "8.8.8.8",
      "8.8.4.4",
      "2001:4860:4860::8888",
      "2001:4860:4860::8844",
    ],
    "dns.quad9.net": [
      "9.9.9.9",
      "149.112.112.112",
      "2620:fe::fe",
      "2620:fe::9",
    ],
    "common.dot.dns.yandex.net": [
      "77.88.8.8",
      "77.88.8.1",
      "2a02:6b8::feed:0ff",
      "2a02:6b8:0:1::feed:0ff",
    ],
    "out.flutterdevs.click": "5.78.58.33",
  },
  "servers": [
    "1.1.1.1",
    {
      "address": "1.1.1.1",
      "domains": ["domain:googleapis.cn", "domain:gstatic.com"],
    },
    {
      "address": "223.5.5.5",
      "domains": [
        "domain:alidns.com",
        "domain:doh.pub",
        "domain:dot.pub",
        "domain:360.cn",
        "domain:onedns.net",
        "geosite:cn",
      ],
      "expectIPs": ["geoip:cn"],
      "skipFallback": true,
    },
  ],
};

class V2rayController extends AsyncNotifier<V2rayService> {
  @override
  Future<V2rayService> build() async {
    final service = await V2rayService.create();
    ref.onDispose(service.dispose);
    return service;
  }

  Future<void> connect({required ConfigModel config}) async {
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
    } catch (e, st) {
      debugPrint('in provider');

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
