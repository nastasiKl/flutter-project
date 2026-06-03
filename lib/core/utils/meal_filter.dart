import '../../features/home/domain/meal_models.dart';

List<MealSummary> filterMealsByName(List<MealSummary> meals, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return meals;
  }
  return meals.where((meal) {
    return meal.name.toLowerCase().contains(normalized) ||
        (meal.category ?? '').toLowerCase().contains(normalized) ||
        (meal.area ?? '').toLowerCase().contains(normalized);
  }).toList();
}
