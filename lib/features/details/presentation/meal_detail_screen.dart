import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/domain/meal_models.dart';
import '../../home/presentation/home_controller.dart';
import '../../user_recipes/data/user_data_repository.dart';

class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meal = ref.watch(mealDetailProvider(id));

    return meal.when(
      data: (data) => _MealDetailContent(meal: data),
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

class _MealDetailContent extends ConsumerWidget {
  const _MealDetailContent({required this.meal});

  final MealDetail meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final repository = ref.watch(userDataRepositoryProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Hero(
            tag: 'meal-${meal.id}',
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                meal.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: Colors.black12,
                    child: Icon(Icons.restaurant_menu, size: 54),
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [meal.category, meal.area]
                              .where(
                                (value) => value != null && value.isNotEmpty,
                              )
                              .join(' • '),
                        ),
                      ],
                    ),
                  ),
                  if (user != null)
                    FutureBuilder<bool>(
                      future: repository.isFavorite(user.id, meal.id),
                      builder: (context, snapshot) {
                        final favorite = snapshot.data ?? false;
                        return IconButton.filledTonal(
                          tooltip: favorite
                              ? l10n.t('removeFromFavorites')
                              : l10n.t('addToFavorites'),
                          onPressed: () async {
                            await repository.toggleFavorite(user.id, meal);
                          },
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.t('ingredients'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...meal.ingredients.map((ingredient) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(ingredient.name),
                  trailing: Text(ingredient.measure),
                );
              }),
              const SizedBox(height: 18),
              Text(
                l10n.t('instructions'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                meal.instructions,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              if ((meal.youtube ?? '').isNotEmpty) ...[
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(l10n.t('video')),
                  subtitle: SelectableText(meal.youtube!),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
