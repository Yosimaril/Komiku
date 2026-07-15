import 'package:komiku/static/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesService(this._sharedPreferences);

  static const String _keyTheme = "KOMIKU_APP_THEME_MODE";

  Future<void> setTheme(AppThemeMode theme) async {
    try {
      await _sharedPreferences.setString(_keyTheme, theme.theme);
    } catch (e) {
      throw Exception("Failed to set theme");
    }
  }

  Future<AppThemeMode> getTheme() async {
    try {
      final theme = _sharedPreferences.getString(_keyTheme);
      return theme == null
          ? AppThemeMode.light
          : AppThemeMode.values.firstWhere((element) => element.theme == theme);
    } catch (e) {
      throw Exception("Failed to get theme");
    }
  }
}
