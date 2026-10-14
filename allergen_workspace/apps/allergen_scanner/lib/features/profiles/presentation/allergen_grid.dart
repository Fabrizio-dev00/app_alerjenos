import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme.dart';
import '../../../core/text/text_normalizer.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/allergen_choice.dart';
import 'allergen_labels.dart';

class AllergenGrid extends StatefulWidget {
  const AllergenGrid({
    required this.selected,
    required this.onChanged,
    this.choices = AllergenChoice.values,
    this.searchable = true,
    super.key,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final List<AllergenChoice> choices;
  final bool searchable;

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
      for (final choice in widget.choices)
        if (query.isEmpty || TextNormalizer.normalize(choice.label(l10n)).contains(query)) choice,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchable) ...[
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l10n.allergensSearch,
              prefixIcon: const Icon(LucideIcons.search, color: SanoColors.coffee),
            ),
          ),
          const SizedBox(height: 16),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 6),
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 100,
          ),
          itemBuilder: (context, index) {
            final choice = visible[index];
            return AllergenTile(
              choice: choice,
              selected: choice.isSelectedIn(widget.selected),
              onTap: () => widget.onChanged(choice.toggle(widget.selected)),
            );
          },
        ),
      ],
    );
  }
}

class AllergenTile extends StatelessWidget {
  const AllergenTile({required this.choice, required this.selected, required this.onTap, super.key});

  final AllergenChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = choice.label(l10n);
    final radius = BorderRadius.circular(22);
    final reduced = SanoMotion.reduced(context);

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
              duration: reduced ? Duration.zero : const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                gradient: selected ? SanoColors.brandGradient : null,
                color: selected ? null : SanoColors.card,
                borderRadius: radius,
                border: Border.all(color: selected ? SanoColors.orange : SanoColors.line),
                boxShadow: SanoShadows.soft,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? SanoColors.card : SanoColors.tracesBg,
                            border: Border.all(color: selected ? Colors.transparent : SanoColors.line),
                          ),
                          child: Icon(choice.icon, size: 22, color: selected ? SanoColors.accent : SanoColors.coffee),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: SanoColors.coffee, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: AnimatedScale(
              scale: selected ? 1 : 0,
              duration: reduced ? Duration.zero : const Duration(milliseconds: 320),
              curve: SanoMotion.pop,
              child: AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SanoColors.card,
                    border: Border.all(color: SanoColors.line),
                  ),
                  child: const Icon(LucideIcons.check, size: 16, color: SanoColors.coffee),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
