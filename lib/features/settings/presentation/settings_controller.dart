import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../domain/settings_state.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final loaded = await ref.read(settingsRepositoryProvider).load();
    state = loaded;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsRepositoryProvider).saveTheme(mode);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await ref.read(settingsRepositoryProvider).saveLocale(locale);
  }
}
