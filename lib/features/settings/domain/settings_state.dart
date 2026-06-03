import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('uk'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
