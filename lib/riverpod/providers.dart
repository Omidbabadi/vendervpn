import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vendervpn/controllers/ad_manager_controller.dart';
import 'package:vendervpn/controllers/v2ray_controller.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:vendervpn/models/user_preferences.dart';
import 'package:vendervpn/riverpod/notifiers.dart';
import 'package:vendervpn/services/v2ray_service.dart';

final v2rayServiceProvider = FutureProvider<V2rayService>((ref) async {
  final service = await V2rayService.create();
  ref.onDispose(service.disconnect);
  return service;
});

final v2rayControllerProvider =
    AsyncNotifierProvider<V2rayController, V2rayService>(
      () => V2rayController(),
    );

final getDelayProvider = StateProvider<bool>((ref) => false);

final configsListProvider =
    StateNotifierProvider<ConfigModelNotifier, List<ConfigModel>>((ref) {
      final box = Hive.box<ConfigModel>('configs');
      return ConfigModelNotifier(box);
    });

final userPrefsBoxProvider = Provider<Box<UserPreferences>>((ref) {
  return Hive.box<UserPreferences>('userPrefs');
});

final userPrefsProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
      final box = ref.watch(userPrefsBoxProvider);

      final prefs =
          box.get(
            'prefs',
            defaultValue: UserPreferences(
              isDarkMode: false,
              languageCode: 'en',
            ),
          )!;
      return UserPreferencesNotifier(box, prefs);
    });

final adManagerProvier = NotifierProvider<AdManagerController, AdManagerState>(
  () => AdManagerController(),
);
