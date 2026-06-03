import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/meal_filter.dart';
import 'home_controller.dart';
import 'widgets/meal_card.dart';

class CategoryMealsScreen extends ConsumerStatefulWidget {
  const CategoryMealsScreen({required this.category, super.key});

  final String category;

  @override
  ConsumerState<CategoryMealsScreen> createState() =>
      _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends ConsumerState<CategoryMealsScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meals = ref.watch(categoryMealsProvider(widget.category));

    return meals.when(
      data: (items) {
        final filtered = filterMealsByName(items, _filter);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoryMealsProvider(widget.category));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: widget.category,
                      hintText: l10n.t('searchHint'),
                      prefixIcon: const Icon(Icons.filter_list),
                    ),
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                );
              }
              final meal = filtered[index - 1];
              return MealCard(
                meal: meal,
                onTap: () => context.push('/meal/${meal.id}'),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error.toString(), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
