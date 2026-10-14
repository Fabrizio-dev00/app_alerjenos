import 'package:core_billing/core_billing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/sano_mascot.dart';
import 'pro_controller.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  static const fallbackPrice = 'USD 3.99';

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _crown = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  bool _celebrating = false;

  @override
  void dispose() {
    _crown.dispose();
    super.dispose();
  }

  void _say(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _celebrate() async {
    setState(() => _celebrating = true);
    if (SanoMotion.reduced(context)) {
      _crown.value = 1;
    } else {
      await _crown.forward(from: 0);
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) context.pop();
  }

  Future<void> _purchase() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref.read(proControllerProvider.notifier).purchase();
    if (!mounted) return;
    switch (outcome) {
      case PurchaseOutcome.purchased:
        await _celebrate();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.pending:
        _say(l10n.purchasePending);
      case PurchaseOutcome.notConfigured:
        _say(l10n.purchaseNotReady);
      case PurchaseOutcome.notAllowed:
        _say(l10n.purchaseNotAllowed);
      case PurchaseOutcome.failed:
        _say(l10n.purchaseFailed);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref.read(proControllerProvider.notifier).restore();
    if (!mounted) return;
    switch (outcome) {
      case RestoreOutcome.restored:
        await _celebrate();
      case RestoreOutcome.nothingToRestore:
        _say(l10n.restoreNothing);
      case RestoreOutcome.notConfigured:
        _say(l10n.purchaseNotReady);
      case RestoreOutcome.failed:
        _say(l10n.restoreFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final pro = ref.watch(proControllerProvider);
    final price = pro.price ?? PaywallScreen.fallbackPrice;
    const light = SanoColors.card;
    final rows = [
      (l10n.proRowScans, '5', l10n.proUnlimited),
      (l10n.profilesTitle, '1', l10n.proUpToSix),
      (l10n.navHistory, l10n.proThirtyDays, l10n.proForever),
      (l10n.proRowLanguages, l10n.yes, l10n.yes),
    ];
    final owned = pro.isPro && !_celebrating;

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
                  AnimatedBuilder(
                    animation: _crown,
                    builder: (context, child) => SanoMascot(
                      mood: SanoMood.happy,
                      size: 96,
                      crowned: true,
                      crownDrop: _celebrating ? Curves.bounceOut.transform(_crown.value) : 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.proBannerTitle, style: textTheme.headlineLarge?.copyWith(color: light)),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _celebrating ? l10n.proWelcome : l10n.proTagline,
                            style: textTheme.bodyLarge?.copyWith(color: light),
                          ),
                        ),
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
                        const Text('Pro', textAlign: TextAlign.center, style: TextStyle(color: SanoColors.accent, fontWeight: FontWeight.w800, fontSize: 17)),
                      ],
                    ),
                    for (final (label, free, proValue) in rows)
                      TableRow(
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: SanoColors.line, width: 2))),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          ),
                          Text(free, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17)),
                          Text(proValue, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SanoColors.accent)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (owned)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.badgeCheck, size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.proAlreadyOwned, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                    ],
                  ),
                )
              else ...[
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
                GradientButton(
                  label: pro.busy ? l10n.proProcessing : l10n.proUnlock(price),
                  onPressed: pro.busy || _celebrating ? null : _purchase,
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: pro.busy || _celebrating ? null : _restore,
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
              ],
              const SizedBox(height: 16),
              Text(l10n.proStoreNote, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: SanoColors.amber)),
            ],
          ),
        ),
      ),
    );
  }
}
