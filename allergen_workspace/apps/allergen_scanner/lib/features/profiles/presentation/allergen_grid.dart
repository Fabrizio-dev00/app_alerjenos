import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/text/text_normalizer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/allergen_choice.dart';
import 'allergen_labels.dart';

class AllergenGrid extends StatefulWidget {
  const AllergenGrid({required this.selected, required this.onChanged, super.key});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<AllergenGrid> createState() => _AllergenGridState();
}

class _AllergenGridState extends State<AllergenGrid> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = TextNormalizer.normalize(_query);
    final visible = [
      for (final choice in AllergenChoice.values)
        if (query.isEmpty || TextNormalizer.normalize(choice.label(l10n)).contains(query)) choice,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: l10n.allergensSearch,
            prefixIcon: const Icon(Icons.search, color: SanoColors.coffee),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 140,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final choice = visible[index];
            return _AllergenTile(
              label: choice.label(l10n),
              selected: choice.isSelectedIn(widget.selected),
              onTap: () => widget.onChanged(choice.toggle(widget.selected)),
            );
          },
        ),
      ],
    );
  }
}

class _AllergenTile extends StatelessWidget {
  const _AllergenTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                gradient: selected ? SanoColors.brandGradient : null,
                color: selected ? null : SanoColors.card,
                borderRadius: radius,
                border: Border.all(color: selected ? SanoColors.orange : SanoColors.line),
                boxShadow: [
                  BoxShadow(color: SanoColors.coffee.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? SanoColors.card : SanoColors.paper,
                            border: Border.all(color: selected ? Colors.transparent : SanoColors.line),
                          ),
                          child: Text(
                            label.characters.first.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: selected ? SanoColors.traces : SanoColors.coffee,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: SanoColors.coffee),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SanoColors.card,
                  border: Border.all(color: SanoColors.line),
                ),
                child: const Icon(Icons.check, size: 16, color: SanoColors.coffee),
              ),
            ),
        ],
      ),
    );
  }
}
