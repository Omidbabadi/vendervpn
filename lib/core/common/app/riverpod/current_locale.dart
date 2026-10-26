import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/services/injection_container.dart';

final currentLocaleProvider = NotifierProvider<CurrentLocale, Locale>(
  CurrentLocale.new,
);

class CurrentLocale extends Notifier<Locale> {
  final _cacheHelper = sl<CacheHelper>();

  @override
  Locale build() {
    final code = _cacheHelper.localeCode;
    return Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _cacheHelper.cacheLocale(languageCode);
  }
}
