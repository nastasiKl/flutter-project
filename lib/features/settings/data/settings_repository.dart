import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_state.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';

  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      themeMode: _themeFromString(prefs.getString(_themeKey)),
      locale: Locale(prefs.getString(_localeKey) ?? 'uk'),
    );
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  ThemeMode _themeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
