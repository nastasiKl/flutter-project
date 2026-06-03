import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/features/home/domain/meal_models.dart';

void main() {
  test('MealDetail parses ingredient and measure pairs', () {
    final meal = MealDetail.fromJson({
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken',
      'strMealThumb': 'https://example.com/meal.jpg',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Cook it gently.',
      'strYoutube': 'https://youtube.com/watch?v=demo',
      'strIngredient1': 'Chicken',
      'strMeasure1': '500g',
      'strIngredient2': 'Soy sauce',
      'strMeasure2': '3 tbsp',
      'strIngredient3': '',
      'strMeasure3': '',
    });

    expect(meal.id, '52772');
    expect(meal.ingredients, hasLength(2));
    expect(meal.ingredients.first.name, 'Chicken');
    expect(meal.ingredients.first.measure, '500g');
  });

  test('MealDetail serializes and restores cached data', () {
    const original = MealDetail(
      id: '1',
      name: 'Soup',
      thumbnail: 'https://example.com/soup.jpg',
      category: 'Starter',
      area: 'Polish',
      instructions: 'Simmer.',
      youtube: 'https://youtube.com/demo',
      ingredients: [MealIngredient(name: 'Water', measure: '1l')],
    );

    final restored = MealDetail.fromCacheJson(original.toJson());

    expect(restored.name, original.name);
    expect(restored.ingredients.single.measure, '1l');
  });

  test('MealCategory parses TheMealDB category json', () {
    final category = MealCategory.fromJson({
      'idCategory': '3',
      'strCategory': 'Dessert',
      'strCategoryThumb': 'https://example.com/dessert.png',
      'strCategoryDescription': 'Sweet recipes',
    });

    expect(category.id, '3');
    expect(category.name, 'Dessert');
    expect(category.toJson()['strCategoryDescription'], 'Sweet recipes');
  });
}
