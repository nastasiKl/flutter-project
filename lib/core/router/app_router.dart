import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/details/presentation/meal_detail_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/category_meals_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/user_recipes/presentation/add_recipe_screen.dart';
import '../firebase/firebase_bootstrap.dart';
import '../l10n/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute =
          path == '/login' || path == '/register' || path == '/forgot';
      final signedIn = authState.asData?.value != null;

      if (authState.isLoading) {
        return null;
      }
      if (!signedIn && !isAuthRoute) {
        return '/login';
      }
      if (signedIn && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(mode: AuthMode.login),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const AuthScreen(mode: AuthMode.register),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/category/:category',
            builder: (context, state) {
              return CategoryMealsScreen(
                category: state.pathParameters['category'] ?? '',
              );
            },
          ),
          GoRoute(
            path: '/meal/:id',
            builder: (context, state) {
              return MealDetailScreen(id: state.pathParameters['id'] ?? '');
            },
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/my-recipe',
            builder: (context, state) => const AddRecipeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(location, l10n)),
        actions: [
          if (!firebaseReady)
            Tooltip(
              message: l10n.t('firebaseDemo'),
              child: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off_outlined),
              ),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(location),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/favorites');
              break;
            case 2:
              context.go('/my-recipe');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.t('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: l10n.t('addRecipe'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.t('profile'),
          ),
        ],
      ),
    );
  }

  int _indexFor(String path) {
    if (path.startsWith('/favorites')) return 1;
    if (path.startsWith('/my-recipe')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  String _titleFor(String path, AppLocalizations l10n) {
    if (path.startsWith('/favorites')) return l10n.t('favorites');
    if (path.startsWith('/my-recipe')) return l10n.t('addRecipe');
    if (path.startsWith('/profile')) return l10n.t('profile');
    if (path.startsWith('/category')) return l10n.t('categories');
    return l10n.t('appName');
  }
}
