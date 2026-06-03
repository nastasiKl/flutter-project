import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/core/l10n/app_localizations.dart';
import 'package:foodhub/core/theme/app_theme.dart';
import 'package:foodhub/features/home/domain/meal_models.dart';
import 'package:foodhub/features/home/presentation/widgets/category_tile.dart';

void main() {
  testWidgets('CategoryTile displays category and handles tap', (tester) async {
    var tapped = false;
    const category = MealCategory(
      id: '1',
      name: 'Dessert',
      thumbnail: 'https://example.com/dessert.png',
      description: 'Sweet recipes',
    );

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 180,
          height: 180,
          child: CategoryTile(category: category, onTap: () => tapped = true),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Dessert'));

    expect(find.text('Dessert'), findsOneWidget);
    expect(tapped, isTrue);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate],
    home: Scaffold(body: Center(child: child)),
  );
}
