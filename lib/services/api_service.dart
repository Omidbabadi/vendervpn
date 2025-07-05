import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:http/http.dart' as http;
import 'package:vendervpn/models/config_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  final String baseUrl = 'http://85.198.16.145:3000/api/v1';
  final String xAppToken =
      '9py9xJcKL3yZrV8g9myQUGXBWBup74ysrqBcewHBCTVTYcmttmUsgu9WgOmnXEI7r2yGBmFVgsAX4WuIT4DCvoyRyOVSXwS2d5ijmEWDld7KaBkgq2VPeJm7QxZxynbb8UjnGaPfpgKXbCeEdvmrT1g05z4lpwIMlfh9TsRvRUrQrQir402fjIM8MJ4sYmO4nfA4dC4ie1ehA3PMWExj5xUgy6T6lZBFYrOfLkj3FBxxBnjD8D3Qdq6iyKLFF2l3wIW3Xk7slEwl6IonGqxpvVLB5KIbYRbdoc2ADhNGNf3YA1qGpwtQAGJe5BgKqfs8LPqXlvXixXFMSdd3sHe46dKaha26Z1jVQZUBlMTwScOO11KE41I1yC3cwq5r1YWYT05sy0TKW47Sy1bBBM0iQN5AXtjelDKAJL5VKlzipr75PURJLMHjPW0MlMrNrCcf2f2GEoDIIJ1CWfcq5KXIUEOTBvOl3274dtZBIq9smIrUAhod5dsm8B4nO6mjQ7N1XcqquICxDqU2cSD6LGZ8qpiqQpLEGdzTrB8oKFQLfVu4aHqIiObqdj084gytAL8uupo2xLg83mWymjTApOqzKv4r5Wh9g2r';
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
  Future<String>? checkServerHash() async {
    final response = await http.get(Uri.parse('api_link/configHash'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint(response.body.toString());
      return data['hash'];
    } else {
      throw Exception('Error Getting Configs Hash: ${response.statusCode}');
    }
  }

  Future<List<ConfigModel>?> getConfigsList() async {
    debugPrint('get ');
    final List<ConfigModel> configsList = [];
    final headers = {'x-app-token': xAppToken};
    final response = await http.get(
      Uri.parse('$baseUrl/configs/list'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final configUrl = item['url'];
        //        final String fullJson = item['fullJson'].toString().trim();
        final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(configUrl);
        final String itemId = item['id'];
        //v2rayURL.dns = dnsServers;
        //final String fullJson = v2rayURL.getFullConfiguration();

        final ConfigModel config = ConfigModel(
          address: v2rayURL.address,
          configjson: v2rayURL.getFullConfiguration(),
          dateAdded: DateTime.now().toIso8601String(),
          importedFrom: 'server',
          port: v2rayURL.port,
          remark: v2rayURL.remark,
          uri: configUrl,
          id: itemId,
        );
        configsList.add(config);
      }

      if (configsList.isEmpty) return null;
      return configsList;
    } else {
      throw Exception('Failed to fetch Configs: ${response.statusCode}');
    }
  }
}
