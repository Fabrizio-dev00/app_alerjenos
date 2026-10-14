import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/home_shell.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../../shared/brand/verdict_pill.dart';
import '../../../shared/language_names.dart';
import '../../../shared/state_card.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../../scan/domain/scan_report.dart';
import '../../scan/presentation/result_screen.dart';
import '../../scan/presentation/scan_quota.dart';
import 'history_providers.dart';

enum HistoryFilter { all, contains, traces, notDetected }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;

  bool _matches(ScanReport report) => switch (_filter) {
        HistoryFilter.all => true,
        HistoryFilter.contains => report.verdict == ScanVerdict.contains,
        HistoryFilter.traces => report.verdict == ScanVerdict.mayContain,
        HistoryFilter.notDetected => report.verdict == ScanVerdict.notDetected,
      };

  String _groupLabel(AppLocalizations l10n, DateTime date, DateTime now) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(day).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(historyRetentionProvider);
    final reports = ref.watch(historyProvider).value ?? const <ScanReport>[];
    final visible = reports.where(_matches).toList();
    final now = ref.read(clockProvider)();
    final profile = ref.watch(activeProfileProvider);

    final groups = <String, List<ScanReport>>{};
    for (final report in visible) {
      groups.putIfAbsent(_groupLabel(l10n, report.createdAt, now), () => []).add(report);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, HomeShell.bottomInset(context)),
          children: [
            Text(l10n.navHistory, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 18),
            _Segmented(
              value: _filter,
              onChanged: (value) => setState(() => _filter = value),
              labels: {
                HistoryFilter.all: l10n.filterAll,
                HistoryFilter.contains: l10n.resultContains,
                HistoryFilter.traces: l10n.filterTraces,
                HistoryFilter.notDetected: l10n.resultNotDetected,
              },
            ),
            const SizedBox(height: 12),
            if (reports.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: StateCard(
                  mood: SanoMood.happy,
                  crowned: ref.watch(isProProvider),
                  title: l10n.historyEmptyTitle,
                  body: l10n.historyEmptyBody,
                  primaryLabel: l10n.scanFirstLabel,
                  onPrimary: () => context.go(AppRoutes.scan),
                  secondaryLabel: l10n.editMyAllergens,
                  onSecondary: profile == null ? null : () => context.push(AppRoutes.profileEditor(profile.id)),
                ),
              )
            else if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(l10n.historyFilterEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              ),
            for (final MapEntry(key: label, value: items) in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: SanoColors.muted),
                ),
              ),
              for (final report in items) ...[
                _HistoryRow(report: report),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged, required this.labels});

  final HistoryFilter value;
  final ValueChanged<HistoryFilter> onChanged;
  final Map<HistoryFilter, String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: SanoColors.field, borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final entry in labels.entries)
              Semantics(
                selected: entry.key == value,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: SanoMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 200),
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: entry.key == value ? SanoColors.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: entry.key == value ? SanoShadows.soft : null,
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: entry.key == value ? FontWeight.w700 : FontWeight.w500,
                        color: entry.key == value ? SanoColors.coffee : SanoColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final verdict = verdictOf(report.verdict);
    final style = VerdictStyle.of(verdict);
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(report.createdAt);
    final name = (report.productName?.isNotEmpty ?? false) ? report.productName! : l10n.unnamedScan;

    return Dismissible(
      key: ValueKey(report.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: SanoColors.contains, borderRadius: BorderRadius.circular(24)),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        final id = report.id;
        if (id != null) ref.read(historyRepositoryProvider).delete(id);
      },
      child: Material(
        color: SanoColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: SanoColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(AppRoutes.result, extra: report),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: verdict == Verdict.notDetected ? SanoColors.card : style.background == SanoColors.tracesBg ? SanoColors.traces : style.background,
                    border: verdict == Verdict.notDetected ? Border.all(color: SanoColors.coffee, width: 2.5) : null,
                  ),
                  child: Icon(
                    style.icon,
                    color: verdict == Verdict.notDetected ? SanoColors.coffee : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(
                        '$time · ${languageName(l10n, report.sourceLanguage)}',
                        style: const TextStyle(fontSize: 15, color: SanoColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                VerdictPill(
                  verdict: verdict,
                  label: verdict == Verdict.mayContain ? l10n.filterTraces : verdictLabel(l10n, report.verdict),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
