import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'brand/gradient_button.dart';
import 'brand/sano_mascot.dart';

class StateCard extends StatelessWidget {
  const StateCard({
    required this.mood,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.crowned = false,
    super.key,
  });

  final SanoMood mood;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool crowned;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: SanoColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: SanoShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: SanoMascot(mood: mood, size: 92, crowned: crowned)),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
          const SizedBox(height: 24),
          GradientButton(label: primaryLabel, onPressed: onPrimary),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(backgroundColor: SanoColors.paper),
              child: Text(secondaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
