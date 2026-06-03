import 'package:flutter/material.dart';

import '../../domain/meal_models.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    required this.meal,
    this.onTap,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final MealSummary meal;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      meal.category,
      meal.area,
    ].where((value) => value != null && value.isNotEmpty).join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Hero(
              tag: 'meal-${meal.id}',
              child: SizedBox(
                width: compact ? 88 : 112,
                height: compact ? 88 : 112,
                child: Image.network(
                  meal.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: const Icon(Icons.restaurant_menu),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
