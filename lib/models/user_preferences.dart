import 'package:hive/hive.dart';
import 'package:vendervpn/models/config_model.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 1)
class UserPreferences extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String languageCode;

  @HiveField(2)
  final ConfigModel? defaultConfig;

  UserPreferences({
    required this.isDarkMode,
    required this.languageCode,
    this.defaultConfig,
  });

  UserPreferences copyWith({
    String? languageCode,
    bool? isDarkMode,
    ConfigModel? defaultConfig,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      defaultConfig: defaultConfig ?? this.defaultConfig,
    );
  }
}
