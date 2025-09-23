import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController({required this.sharedPreferences}) {
    final stored = sharedPreferences.getString(_storageKey);
    switch (stored) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  static const String _storageKey = 'app_theme_mode';
  final SharedPreferences sharedPreferences;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleThemeMode() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    switch (mode) {
      case ThemeMode.light:
        sharedPreferences.setString(_storageKey, 'light');
        break;
      case ThemeMode.dark:
        sharedPreferences.setString(_storageKey, 'dark');
        break;
      case ThemeMode.system:
        sharedPreferences.remove(_storageKey);
        break;
    }
    update();
  }
}
