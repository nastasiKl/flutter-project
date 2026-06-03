import 'package:flutter_test/flutter_test.dart';
import 'package:foodhub/features/home/data/meal_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('TheMealDbRepository fetchCategories decodes categories', () async {
    final repository = TheMealDbRepository(
      MockClient((request) async {
        expect(request.url.path, endsWith('/categories.php'));
        return http.Response('''
          {"categories":[
            {
              "idCategory":"1",
              "strCategory":"Beef",
              "strCategoryThumb":"beef.png",
              "strCategoryDescription":"Beef meals"
            }
          ]}
        ''', 200);
      }),
    );

    final categories = await repository.fetchCategories();

    expect(categories.single.name, 'Beef');
  });

  test(
    'TheMealDbRepository fetchMeal caches recently viewed recipes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = TheMealDbRepository(
        MockClient((request) async {
          return http.Response('''
          {"meals":[
            {
              "idMeal":"10",
              "strMeal":"Apple Pie",
              "strMealThumb":"pie.jpg",
              "strCategory":"Dessert",
              "strArea":"American",
              "strInstructions":"Bake.",
              "strIngredient1":"Apple",
              "strMeasure1":"3"
            }
          ]}
        ''', 200);
        }),
      );

      await repository.fetchMeal('10');
      final recent = await repository.loadRecentMeals();

      expect(recent.single.name, 'Apple Pie');
      expect(recent.single.ingredients.single.name, 'Apple');
    },
  );

  test(
    'TheMealDbRepository submitSearchFeedback uses POST without blocking',
    () async {
      var posted = false;
      final repository = TheMealDbRepository(
        MockClient((request) async {
          if (request.method == 'POST') {
            posted = true;
            return http.Response('{"ok":true}', 200);
          }
          return http.Response('{"meals":[]}', 200);
        }),
      );

      await repository.submitSearchFeedback('chicken');

      expect(posted, isTrue);
    },
  );
}
