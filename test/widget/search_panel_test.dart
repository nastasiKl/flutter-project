import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/core/l10n/app_localizations.dart';
import 'package:foodhub/core/theme/app_theme.dart';
import 'package:foodhub/features/home/presentation/home_controller.dart';
import 'package:foodhub/features/home/presentation/widgets/search_panel.dart';

void main() {
  testWidgets('SearchPanel changes mode and submits query', (tester) async {
    var mode = SearchMode.name;
    var submitted = '';

    await tester.pumpWidget(
      _wrap(
        SearchPanel(
          mode: mode,
          onModeChanged: (value) => mode = value,
          onSearch: (value) => submitted = value,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ingredient'));
    await tester.enterText(find.byType(TextField), 'tomato');
    await tester.tap(find.byIcon(Icons.arrow_forward));

    expect(mode, SearchMode.ingredient);
    expect(submitted, 'tomato');
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate],
    home: Scaffold(body: child),
  );
}
