import 'dart:async';
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
    setTheme(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    // Skip no-op toggles so we never emit an identical state (which would
    // otherwise trigger a redundant MaterialApp rebuild).
    if (mode == state) return;

    // Repaint the UI first so the switch feels instant, then persist. Box.put
    // returns a Future (the disk flush is async); we deliberately fire it and
    // forget so the theme change is never gated on disk I/O on the UI thread.
    emit(mode);
    unawaited(_settingsBox.put(_themeKey, _encode(mode)));
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
