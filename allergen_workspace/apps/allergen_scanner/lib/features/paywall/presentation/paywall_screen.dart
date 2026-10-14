import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/sano_mascot.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const price = 'USD 3.99';

  void _notReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).purchaseNotReady)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    const light = SanoColors.card;
    final rows = [
      (l10n.proRowScans, '5', l10n.proUnlimited),
      (l10n.profilesTitle, '1', l10n.proUpToSix),
      (l10n.navHistory, l10n.proThirtyDays, l10n.proForever),
      (l10n.proRowLanguages, l10n.yes, l10n.yes),
    ];

    return Scaffold(
      backgroundColor: SanoColors.coffee,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: SanoColors.proBackground),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(LucideIcons.x, color: light, size: 30),
                ),
              ),
              Row(
                children: [
                  const SanoMascot(mood: SanoMood.happy, size: 96, crowned: true),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.proBannerTitle, style: textTheme.headlineLarge?.copyWith(color: light)),
                        Text(l10n.proTagline, style: textTheme.bodyLarge?.copyWith(color: light)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                decoration: BoxDecoration(color: SanoColors.card, borderRadius: BorderRadius.circular(32)),
                child: Table(
                  columnWidths: const {0: FlexColumnWidth(1.4), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        const SizedBox(height: 40),
                        Text(l10n.proFree, textAlign: TextAlign.center, style: const TextStyle(color: SanoColors.muted, fontSize: 17)),
                        Text('Pro', textAlign: TextAlign.center, style: const TextStyle(color: SanoColors.accent, fontWeight: FontWeight.w800, fontSize: 17)),
                      ],
                    ),
                    for (final (label, free, pro) in rows)
                      TableRow(
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: SanoColors.line, width: 2))),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          ),
                          Text(free, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17)),
                          Text(pro, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SanoColors.accent)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(price, style: textTheme.displaySmall?.copyWith(color: light, fontSize: 48)),
                  Text(l10n.proOneTime, style: textTheme.bodyLarge?.copyWith(color: light)),
                ],
              ),
              const SizedBox(height: 28),
              GradientButton(label: l10n.proUnlock(price), onPressed: () => _notReady(context)),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _notReady(context),
                    style: TextButton.styleFrom(foregroundColor: light),
                    child: Text(l10n.proRestore, style: const TextStyle(decoration: TextDecoration.underline, decorationColor: light)),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(foregroundColor: light),
                    child: Text(l10n.proNotNow, style: const TextStyle(decoration: TextDecoration.underline, decorationColor: light)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.proStoreNote, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: SanoColors.amber)),
            ],
          ),
        ),
      ),
    );
  }
}
