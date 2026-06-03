import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import 'home_controller.dart';
import 'widgets/category_tile.dart';
import 'widgets/meal_card.dart';
import 'widgets/search_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final home = ref.watch(homeControllerProvider);
    final search = ref.watch(searchControllerProvider);
    final searchState = search.asData?.value ?? const SearchState();

    return RefreshIndicator(
      onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: SearchPanel(
                mode: searchState.mode,
                isLoading: search.isLoading,
                onModeChanged: ref
                    .read(searchControllerProvider.notifier)
                    .setMode,
                onSearch: ref.read(searchControllerProvider.notifier).search,
              ),
            ),
          ),
          if (searchState.query.isNotEmpty || search.isLoading)
            _SearchResults(search: search)
          else
            home.when(
              data: (data) => _HomeContent(data: data),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: _ErrorState(
                  message: error.toString(),
                  onRetry: () {
                    ref.read(homeControllerProvider.notifier).refresh();
                  },
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.t('pullToRefresh'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeState data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900
        ? 5
        : width >= 620
        ? 4
        : 2;

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('recipeOfDay'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                MealCard(
                  meal: data.randomMeal,
                  onTap: () => context.push('/meal/${data.randomMeal.id}'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.t('categories'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.builder(
            itemCount: data.categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final category = data.categories[index];
              return CategoryTile(
                category: category,
                onTap: () => context.push('/category/${category.name}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.search});

  final AsyncValue<SearchState> search;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return search.when(
      data: (state) {
        if (state.results.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(l10n.t('noResults'))),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final meal = state.results[index];
              return FadeInListItem(
                index: index,
                child: MealCard(
                  meal: meal,
                  onTap: () => context.push('/meal/${meal.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) =>
          SliverFillRemaining(child: _ErrorState(message: error.toString())),
    );
  }
}

class FadeInListItem extends StatefulWidget {
  const FadeInListItem({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  State<FadeInListItem> createState() => _FadeInListItemState();
}

class _FadeInListItemState extends State<FadeInListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 220 + widget.index.clamp(0, 6).toInt() * 35,
      ),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.t('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
