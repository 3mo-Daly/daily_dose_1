import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Box _settingsBox;
  static const _themeKey = 'themeMode';

  ThemeCubit(this._settingsBox) : super(_loadInitialTheme(_settingsBox));

  static ThemeMode _loadInitialTheme(Box box) {
    final saved = box.get(_themeKey, defaultValue: 'system') as String;
    switch (saved) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void toggleTheme(bool isCurrentlyDark) {
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    _settingsBox.put(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }

  void setTheme(ThemeMode mode) {
    final String key;
    switch (mode) {
      case ThemeMode.dark:
        key = 'dark';
        break;
      case ThemeMode.light:
        key = 'light';
        break;
      default:
        key = 'system';
    }
    _settingsBox.put(_themeKey, key);
    emit(mode);
  }
}
