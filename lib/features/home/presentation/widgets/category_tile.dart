import 'package:flutter/material.dart';

import '../../domain/meal_models.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({required this.category, required this.onTap, super.key});

  final MealCategory category;
  final VoidCallback onTap;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _hovered
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.network(
                  widget.category.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.dinner_dining,
                      size: 42,
                      color: scheme.primary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
