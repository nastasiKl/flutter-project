import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/core/l10n/app_localizations.dart';
import 'package:foodhub/core/theme/app_theme.dart';
import 'package:foodhub/features/home/domain/meal_models.dart';
import 'package:foodhub/features/home/presentation/widgets/meal_card.dart';

void main() {
  testWidgets('MealCard renders recipe title and metadata', (tester) async {
    const meal = MealSummary(
      id: '1',
      name: 'Chicken Curry',
      thumbnail: 'https://example.com/chicken.jpg',
      category: 'Chicken',
      area: 'Indian',
    );

    await tester.pumpWidget(_wrap(const MealCard(meal: meal)));
    await tester.pump();

    expect(find.text('Chicken Curry'), findsOneWidget);
    expect(find.text('Chicken • Indian'), findsOneWidget);
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
