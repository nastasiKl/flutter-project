import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/meal_filter.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/domain/meal_models.dart';
import '../../home/presentation/widgets/meal_card.dart';
import '../../user_recipes/data/user_data_repository.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final repository = ref.watch(userDataRepositoryProvider);

    if (user == null) {
      return Center(child: Text(l10n.t('protectedInfo')));
    }

    return StreamBuilder(
      stream: repository.watchFavorites(user.id),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? [];
        final meals = favorites
            .map(
              (item) => MealSummary(
                id: item.id,
                name: item.name,
                thumbnail: item.thumbnail,
              ),
            )
            .toList();
        final filtered = filterMealsByName(meals, _filter);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.t('searchHint'),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _filter = value),
                ),
              );
            }
            final meal = filtered[index - 1];
            return MealCard(
              meal: meal,
              onTap: () => context.push('/meal/${meal.id}'),
              trailing: IconButton(
                tooltip: l10n.t('removeFromFavorites'),
                onPressed: () {
                  repository.toggleFavorite(user.id, meal);
                },
                icon: const Icon(Icons.delete_outline),
              ),
            );
          },
        );
      },
    );
  }
}
