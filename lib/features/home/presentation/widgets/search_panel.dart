import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../home_controller.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({
    required this.mode,
    required this.onModeChanged,
    required this.onSearch,
    this.isLoading = false,
    super.key,
  });

  final SearchMode mode;
  final ValueChanged<SearchMode> onModeChanged;
  final ValueChanged<String> onSearch;
  final bool isLoading;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<SearchMode>(
              segments: [
                ButtonSegment(
                  value: SearchMode.name,
                  icon: const Icon(Icons.badge_outlined),
                  label: Text(l10n.t('byName')),
                ),
                ButtonSegment(
                  value: SearchMode.ingredient,
                  icon: const Icon(Icons.egg_alt_outlined),
                  label: Text(l10n.t('byIngredient')),
                ),
              ],
              selected: {widget.mode},
              onSelectionChanged: (value) {
                widget.onModeChanged(value.first);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.t('searchHint'),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: widget.onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox.square(
                  dimension: 56,
                  child: FilledButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => widget.onSearch(_controller.text),
                    child: widget.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
