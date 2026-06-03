class MealCategory {
  const MealCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  final String id;
  final String name;
  final String thumbnail;
  final String description;

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'] as String? ?? '',
      name: json['strCategory'] as String? ?? '',
      thumbnail: json['strCategoryThumb'] as String? ?? '',
      description: json['strCategoryDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnail,
      'strCategoryDescription': description,
    };
  }
}

class MealSummary {
  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.category,
    this.area,
  });

  final String id;
  final String name;
  final String thumbnail;
  final String? category;
  final String? area;

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': thumbnail,
      'strCategory': category,
      'strArea': area,
    };
  }
}

class MealIngredient {
  const MealIngredient({required this.name, required this.measure});

  final String name;
  final String measure;

  Map<String, dynamic> toJson() => {'name': name, 'measure': measure};

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    return MealIngredient(
      name: json['name'] as String? ?? '',
      measure: json['measure'] as String? ?? '',
    );
  }
}

class MealDetail extends MealSummary {
  const MealDetail({
    required super.id,
    required super.name,
    required super.thumbnail,
    required this.instructions,
    required this.ingredients,
    super.category,
    super.area,
    this.youtube,
  });

  final String instructions;
  final String? youtube;
  final List<MealIngredient> ingredients;

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (var index = 1; index <= 20; index++) {
      final ingredient = (json['strIngredient$index'] as String? ?? '').trim();
      final measure = (json['strMeasure$index'] as String? ?? '').trim();
      if (ingredient.isNotEmpty) {
        ingredients.add(MealIngredient(name: ingredient, measure: measure));
      }
    }

    return MealDetail(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String? ?? '',
      youtube: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }

  factory MealDetail.fromCacheJson(Map<String, dynamic> json) {
    return MealDetail(
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      thumbnail: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String? ?? '',
      youtube: json['strYoutube'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MealIngredient.fromJson)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'strInstructions': instructions,
      'strYoutube': youtube,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
    };
  }
}
