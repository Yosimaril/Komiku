import 'package:flutter/widgets.dart';
import 'package:komiku/services/shared_preferences_service.dart';
import 'package:komiku/static/app_theme_mode.dart';

class ThemeStateProvider extends ChangeNotifier {
  final SharedPreferencesService _preferencesService;

  ThemeStateProvider(this._preferencesService) {
    _loadTheme();
  }

  AppThemeMode _themeMode = AppThemeMode.light;

  AppThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    _themeMode = await _preferencesService.getTheme();
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    await _preferencesService.setTheme(mode);
  }
}
