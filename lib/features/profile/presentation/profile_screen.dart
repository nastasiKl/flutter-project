import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/presentation/home_controller.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../user_recipes/data/user_data_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final settings = ref.watch(settingsControllerProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    if (user == null) {
      return Center(child: Text(l10n.t('protectedInfo')));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            child: Text(user.email.characters.first.toUpperCase()),
          ),
          title: Text(user.displayName ?? user.email),
          subtitle: Text(user.email),
        ),
        if (!firebaseReady)
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_off_outlined),
              title: Text(l10n.t('firebaseDemo')),
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.t('darkMode')),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: settings.themeMode == ThemeMode.dark,
          onChanged: (enabled) {
            ref
                .read(settingsControllerProvider.notifier)
                .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.translate),
          title: Text(l10n.t('language')),
          trailing: DropdownButton<Locale>(
            value: settings.locale,
            items: const [
              DropdownMenuItem(value: Locale('uk'), child: Text('UK')),
              DropdownMenuItem(value: Locale('en'), child: Text('EN')),
              DropdownMenuItem(value: Locale('pl'), child: Text('PL')),
            ],
            onChanged: (locale) {
              if (locale != null) {
                ref.read(settingsControllerProvider.notifier).setLocale(locale);
              }
            },
          ),
        ),
        const Divider(),
        Text(
          l10n.t('recentMeals'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ref
            .watch(recentMealsProvider)
            .when(
              data: (meals) => meals.isEmpty
                  ? Text(l10n.t('noResults'))
                  : Column(
                      children: meals
                          .map(
                            (meal) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  meal.thumbnail,
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(meal.name),
                              subtitle: Text(meal.category ?? ''),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Text(error.toString()),
            ),
        const Divider(),
        Text(
          l10n.t('myRecipes'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: ref.watch(userDataRepositoryProvider).watchRecipes(user.id),
          builder: (context, snapshot) {
            final recipes = snapshot.data ?? [];
            if (recipes.isEmpty) {
              return Text(l10n.t('noResults'));
            }
            return Column(
              children: recipes
                  .map(
                    (recipe) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.menu_book_outlined),
                      title: Text(recipe.title),
                      subtitle: Text('${recipe.category} • ${recipe.servings}'),
                      trailing: IconButton(
                        onPressed: () {
                          ref
                              .read(userDataRepositoryProvider)
                              .deleteRecipe(user.id, recipe.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
          label: Text(l10n.t('logout')),
        ),
      ],
    );
  }
}
