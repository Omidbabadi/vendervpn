import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/models/config_model.dart';
import 'package:hive/hive.dart';
import 'package:vendervpn/models/user_preferences.dart';

class ConfigModelNotifier extends StateNotifier<List<ConfigModel>> {
  final Box<ConfigModel> _box;

  ConfigModelNotifier(this._box) : super([]) {
    _loadConfigs();
  }

  void _loadConfigs() {
    state = _box.values.toList();
  }

  void addConfig(ConfigModel newConfig) async {
    await _box.add(newConfig);
    state = _box.values.toList();
  }

  void removeConfig(String id) async {
    final keyToDelete = _box.keys.firstWhere(
      (key) => _box.get(key)?.id == id,
      orElse: () => null,
    );
    if (keyToDelete != null) {
      await _box.delete(keyToDelete);
      state = _box.values.toList();
    }
    // state = state.where((c) => c.id != id).toList();
  }

  void updateConfig(String id, ConfigModel updated) {
    state = state.map((c) => c.id == id ? updated : c).toList();
  }

  void reorderConfigs(int oldIndex, int newIndex) {
    final newList = [...state];
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    state = newList;
    _box.clear();
    for (final config in newList) {
      _box.add(config);
    }
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final Box<UserPreferences> _box;
  UserPreferencesNotifier(this._box, UserPreferences initialPrefs)
    : super(initialPrefs);

  void setLanguage(String code) {
    state = state.copyWith(languageCode: code);

    _box.put('prefs', state);
  }

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _box.put('prefs', state);
  }

  void setDarkMode(bool enabled) {
    state = state.copyWith(isDarkMode: enabled);
    _box.put('prefs', state);
  }

  void setDefaultConfig(ConfigModel config) {
    state = state.copyWith(defaultConfig: config);
    _box.put('prefs', state);
  }

  void unSetDefualtConfig() {
    state = state.copyWith(defaultConfig: null);
    _box.put('prefs', state);
  }
}
