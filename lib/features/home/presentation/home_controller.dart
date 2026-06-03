import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/meal_repository.dart';
import '../domain/meal_models.dart';

final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

final searchControllerProvider =
    AsyncNotifierProvider<MealSearchController, SearchState>(
      MealSearchController.new,
    );

final categoryMealsProvider = FutureProvider.family<List<MealSummary>, String>((
  ref,
  category,
) {
  return ref.watch(mealRepositoryProvider).fetchByCategory(category);
});

final mealDetailProvider = FutureProvider.family<MealDetail, String>((ref, id) {
  return ref.watch(mealRepositoryProvider).fetchMeal(id);
});

final recentMealsProvider = FutureProvider<List<MealDetail>>((ref) {
  return ref.watch(mealRepositoryProvider).loadRecentMeals();
});

class HomeState {
  const HomeState({required this.categories, required this.randomMeal});

  final List<MealCategory> categories;
  final MealDetail randomMeal;
}

class HomeController extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    return _load();
  }

  Future<HomeState> _load() async {
    final repository = ref.watch(mealRepositoryProvider);
    final categories = await repository.fetchCategories();
    final randomMeal = await repository.fetchRandomMeal();
    return HomeState(categories: categories, randomMeal: randomMeal);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

enum SearchMode { name, ingredient }

class SearchState {
  const SearchState({
    this.query = '',
    this.mode = SearchMode.name,
    this.results = const [],
  });

  final String query;
  final SearchMode mode;
  final List<MealSummary> results;

  SearchState copyWith({
    String? query,
    SearchMode? mode,
    List<MealSummary>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      mode: mode ?? this.mode,
      results: results ?? this.results,
    );
  }
}

class MealSearchController extends AsyncNotifier<SearchState> {
  @override
  Future<SearchState> build() async => const SearchState();

  void setMode(SearchMode mode) {
    final current = state.asData?.value ?? const SearchState();
    state = AsyncData(current.copyWith(mode: mode));
  }

  Future<void> search(String query) async {
    final repository = ref.read(mealRepositoryProvider);
    final current = state.asData?.value ?? const SearchState();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = AsyncData(current.copyWith(query: '', results: []));
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results = current.mode == SearchMode.name
          ? await repository.searchByName(trimmed)
          : await repository.searchByIngredient(trimmed);
      await repository.submitSearchFeedback(trimmed);
      return current.copyWith(query: trimmed, results: results);
    });
  }
}
