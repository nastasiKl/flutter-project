import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../domain/meal_models.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return TheMealDbRepository(ref.watch(httpClientProvider));
});

abstract class MealRepository {
  Future<List<MealCategory>> fetchCategories();
  Future<MealDetail> fetchRandomMeal();
  Future<List<MealSummary>> searchByName(String query);
  Future<List<MealSummary>> searchByIngredient(String query);
  Future<List<MealSummary>> fetchByCategory(String category);
  Future<MealDetail> fetchMeal(String id);
  Future<void> submitSearchFeedback(String query);
  Future<List<MealDetail>> loadRecentMeals();
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TheMealDbRepository implements MealRepository {
  TheMealDbRepository(this._client);

  final http.Client _client;
  static const _recentKey = 'cache.recentMeals';

  @override
  Future<List<MealCategory>> fetchCategories() async {
    final data = await _get('/categories.php');
    return (data['categories'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MealCategory.fromJson)
        .toList();
  }

  @override
  Future<MealDetail> fetchRandomMeal() async {
    final data = await _get('/random.php');
    final meals = data['meals'] as List<dynamic>? ?? [];
    if (meals.isEmpty) {
      throw ApiException('TheMealDB did not return a random recipe.');
    }
    return MealDetail.fromJson(meals.first as Map<String, dynamic>);
  }

  @override
  Future<List<MealSummary>> searchByName(String query) async {
    final data = await _get('/search.php', {'s': query});
    return _parseMealList(data);
  }

  @override
  Future<List<MealSummary>> searchByIngredient(String query) async {
    final data = await _get('/filter.php', {'i': query});
    return _parseMealList(data);
  }

  @override
  Future<List<MealSummary>> fetchByCategory(String category) async {
    final data = await _get('/filter.php', {'c': category});
    return _parseMealList(data);
  }

  @override
  Future<MealDetail> fetchMeal(String id) async {
    final data = await _get('/lookup.php', {'i': id});
    final meals = data['meals'] as List<dynamic>? ?? [];
    if (meals.isEmpty) {
      throw ApiException('Recipe $id was not found.');
    }
    final meal = MealDetail.fromJson(meals.first as Map<String, dynamic>);
    await _cacheRecentMeal(meal);
    return meal;
  }

  @override
  Future<void> submitSearchFeedback(String query) async {
    if (query.trim().isEmpty) {
      return;
    }
    try {
      await _client.post(
        Uri.parse(ApiConstants.feedbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app': 'FoodHub',
          'query': query,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } on Object {
      // TheMealDB is GET-only; this optional public POST must not block search.
    }
  }

  @override
  Future<List<MealDetail>> loadRecentMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(MealDetail.fromCacheJson)
        .toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse(
      '${ApiConstants.mealDbBaseUrl}$path',
    ).replace(queryParameters: query);
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('API error ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<MealSummary> _parseMealList(Map<String, dynamic> data) {
    return (data['meals'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MealSummary.fromJson)
        .toList();
  }

  Future<void> _cacheRecentMeal(MealDetail meal) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadRecentMeals();
    final updated = [
      meal,
      ...current.where((item) => item.id != meal.id),
    ].take(8).map((item) => item.toJson()).toList();
    await prefs.setString(_recentKey, jsonEncode(updated));
  }
}
