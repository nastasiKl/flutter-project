import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_controller.dart';

class FoodHubApp extends ConsumerWidget {
  const FoodHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'FoodHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
