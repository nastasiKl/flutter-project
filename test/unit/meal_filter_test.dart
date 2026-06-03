import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/core/utils/meal_filter.dart';
import 'package:foodhub/features/home/domain/meal_models.dart';

void main() {
  test('filterMealsByName matches name, category, and area', () {
    const meals = [
      MealSummary(
        id: '1',
        name: 'Beef Wellington',
        thumbnail: 'beef.jpg',
        category: 'Beef',
        area: 'British',
      ),
      MealSummary(
        id: '2',
        name: 'Pierogi',
        thumbnail: 'pierogi.jpg',
        category: 'Vegetarian',
        area: 'Polish',
      ),
    ];

    expect(filterMealsByName(meals, 'polish').single.name, 'Pierogi');
    expect(filterMealsByName(meals, 'beef'), hasLength(1));
    expect(filterMealsByName(meals, ''), hasLength(2));
  });
}
