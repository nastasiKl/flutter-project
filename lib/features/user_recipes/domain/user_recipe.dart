import '../../home/domain/meal_models.dart';

class FavoriteRecipe {
  const FavoriteRecipe({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String thumbnail;
  final DateTime createdAt;

  factory FavoriteRecipe.fromMeal(MealSummary meal) {
    return FavoriteRecipe(
      id: meal.id,
      name: meal.name,
      thumbnail: meal.thumbnail,
      createdAt: DateTime.now(),
    );
  }

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class UserRecipeDraft {
  const UserRecipeDraft({
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.servings,
    required this.notes,
  });

  final String title;
  final String category;
  final String ingredients;
  final String steps;
  final int servings;
  final String notes;
}

class UserRecipe {
  const UserRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.servings,
    required this.notes,
    required this.createdAt,
    this.photoUrl,
  });

  final String id;
  final String title;
  final String category;
  final String ingredients;
  final String steps;
  final int servings;
  final String notes;
  final String? photoUrl;
  final DateTime createdAt;

  factory UserRecipe.fromJson(Map<String, dynamic> json, String id) {
    return UserRecipe(
      id: id,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      ingredients: json['ingredients'] as String? ?? '',
      steps: json['steps'] as String? ?? '',
      servings: json['servings'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
      'servings': servings,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
