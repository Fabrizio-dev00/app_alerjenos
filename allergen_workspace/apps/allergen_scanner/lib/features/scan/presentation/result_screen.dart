import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../../../shared/brand/verdict_pill.dart';
import '../../../shared/language_names.dart';
import '../../../shared/safety_notice.dart';
import '../../history/presentation/history_providers.dart';
import '../../profiles/presentation/allergen_labels.dart';
import '../domain/allergen_matcher.dart';
import '../domain/scan_report.dart';

Verdict verdictOf(ScanVerdict verdict) => switch (verdict) {
      ScanVerdict.contains => Verdict.contains,
      ScanVerdict.mayContain => Verdict.mayContain,
      ScanVerdict.notDetected || ScanVerdict.unreadable => Verdict.notDetected,
    };

String verdictLabel(AppLocalizations l10n, ScanVerdict verdict) => switch (verdict) {
      ScanVerdict.contains => l10n.resultContains,
      ScanVerdict.mayContain => l10n.resultMayContain,
      ScanVerdict.notDetected || ScanVerdict.unreadable => l10n.resultNotDetected,
    };

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.report, super.key});

  final ScanReport report;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ScanReport _report = widget.report;
  bool _named = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameDialog(initial: _report.productName ?? _report.suggestedName),
    );
    if (name == null || !mounted) return;
    final saved = await ref.read(historyRepositoryProvider).save(_report.copyWith(productName: name.trim()));
    if (!mounted) return;
    setState(() {
      _report = saved.copyWith(productName: name.trim());
      _named = true;
    });
    SemanticsService.sendAnnouncement(View.of(context), l10n.savedToHistory, Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = _report;
    final notDetected = report.verdict == ScanVerdict.notDetected || report.verdict == ScanVerdict.unreadable;

    return Scaffold(
      backgroundColor: SanoColors.coffee,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PhotoWithHighlights(report: report),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      icon: const Icon(LucideIcons.chevronLeft, color: SanoColors.card, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: SanoColors.paper,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(color: SanoColors.coffee.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      children: [
                        _Header(report: report),
                        const SizedBox(height: 16),
                        for (final (index, hit) in [...report.containsHits, ...report.traceHits].indexed)
                          _Staggered(index: index, child: _HitRow(hit: hit)),
                        if (notDetected) _Checked(report: report),
                        _TextCards(report: report),
                        const SizedBox(height: 16),
                        SafetyNotice(dark: notDetected),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: OutlinedButton.icon(
                              onPressed: _save,
                              icon: _named ? const Icon(LucideIcons.check) : const SizedBox.shrink(),
                              label: Text(_named ? l10n.saved : l10n.save),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: GradientButton(label: l10n.scanAnother, onPressed: () => context.go(AppRoutes.scan)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.saveScanTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l10n.saveScanHint, counterText: ''),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text(l10n.save)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final pill = VerdictPill(verdict: verdictOf(report.verdict), label: verdictLabel(l10n, report.verdict), large: true);
    final subtitle = switch (report.verdict) {
      ScanVerdict.contains => l10n.resultContainsSubtitle(report.containsHits.length, report.profileName),
      ScanVerdict.mayContain => l10n.resultTracesSubtitle(report.traceHits.length, report.profileName),
      _ => l10n.resultNotDetectedSubtitle(report.profileName),
    };
    final source = languageName(l10n, report.sourceLanguage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            pill,
            if (report.verdict == ScanVerdict.contains)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(subtitle, style: textTheme.bodyLarge?.copyWith(color: SanoColors.muted)),
              ),
          ],
        ),
        if (report.verdict != ScanVerdict.contains) ...[
          const SizedBox(height: 12),
          Text(subtitle, style: textTheme.bodyLarge?.copyWith(color: SanoColors.muted)),
        ],
        if (report.sourceLanguage != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.languages, size: 20, color: SanoColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report.wasTranslated
                      ? l10n.readInTranslated(source, languageName(l10n, report.targetLanguage))
                      : l10n.readIn(source),
                  style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HitRow extends StatelessWidget {
  const _HitRow({required this.hit});

  final AllergenHit hit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contains = hit.level == MatchLevel.contains;
    final color = contains ? SanoColors.contains : SanoColors.traces;
    final title = contains
        ? hit.choice.label(l10n)
        : hit.possible
            ? l10n.allergenPossible(hit.choice.label(l10n))
            : l10n.allergenTraces(hit.choice.label(l10n));
    final evidence = [hit.original, hit.translated].whereType<String>().toSet().join(' → ');

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Icon(hit.choice.icon, color: Colors.white, size: 28),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SanoColors.card,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Icon(contains ? LucideIcons.x : LucideIcons.triangle, size: 14, color: color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: contains ? SanoColors.coffee : SanoColors.traces)),
                if (evidence.isNotEmpty)
                  Text(evidence, style: const TextStyle(fontSize: 16, color: SanoColors.muted, height: 1.3)),
                if (hit.possible) Text(l10n.possibleHint, style: const TextStyle(fontSize: 14, color: SanoColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: contains
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: SanoColors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: SanoShadows.soft,
              ),
              child: content,
            )
          : CustomPaint(
              foregroundPainter: const DashedBorderPainter(color: SanoColors.traces, radius: 24, strokeWidth: 2.5),
              child: DecoratedBox(
                decoration: BoxDecoration(color: SanoColors.tracesBg, borderRadius: BorderRadius.circular(24)),
                child: content,
              ),
            ),
    );
  }
}

class _Checked extends StatelessWidget {
  const _Checked({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      l10n.checkedIngredients(report.ingredientCount, languageName(l10n, report.sourceLanguage)),
      report.wasTranslated ? l10n.checkedBothTexts : l10n.checkedOriginal,
      l10n.checkedQuality,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.checkedTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(LucideIcons.check, color: SanoColors.orange, size: 24),
                  const SizedBox(width: 14),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 17))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TextCards extends StatelessWidget {
  const _TextCards({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = languageName(l10n, report.sourceLanguage);

    Widget card(String title, String body) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SanoColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: SanoColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: SanoColors.accent, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(body, maxLines: 8, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.35)),
              ],
            ),
          ),
        );

    final translated = report.translatedSection;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card(report.wasTranslated ? l10n.originalIn(source) : l10n.readText, report.originalSection),
          if (report.wasTranslated && translated != null) ...[
            const SizedBox(width: 12),
            card(l10n.translatedIn(languageName(l10n, report.targetLanguage)), translated),
          ],
        ],
      ),
    );
  }
}

class _Staggered extends StatefulWidget {
  const _Staggered({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<_Staggered> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = SanoMotion.reduced(context);
    return AnimatedOpacity(
      opacity: _visible || reduced ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      child: AnimatedSlide(
        offset: _visible || reduced ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 320),
        curve: SanoMotion.sheet,
        child: widget.child,
      ),
    );
  }
}

class _PhotoWithHighlights extends StatelessWidget {
  const _PhotoWithHighlights({required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final file = File(report.imagePath);
    if (!file.existsSync() || report.imageWidth <= 0 || report.imageHeight <= 0) {
      return const DecoratedBox(decoration: BoxDecoration(gradient: SanoColors.darkBackground));
    }
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: SanoColors.darkBackground),
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: _focus(),
          child: SizedBox(
            width: report.imageWidth,
            height: report.imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(file, fit: BoxFit.fill, cacheWidth: 1080, errorBuilder: (context, error, stack) => const SizedBox.shrink()),
                CustomPaint(painter: _HighlightPainter(report.highlights)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _focus() {
    if (report.highlights.isEmpty) return Alignment.center;
    final center = report.highlights
            .map((h) => h.box.top + h.box.height / 2)
            .reduce((a, b) => a + b) /
        report.highlights.length;
    return Alignment(0, (center / report.imageHeight) * 2 - 1);
  }
}

class _HighlightPainter extends CustomPainter {
  _HighlightPainter(this.highlights);

  final List<HighlightBox> highlights;

  @override
  void paint(Canvas canvas, Size size) {
    for (final highlight in highlights) {
      final color = highlight.level == MatchLevel.contains ? SanoColors.contains : SanoColors.amber;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(highlight.box.left, highlight.box.top, highlight.box.width, highlight.box.height).inflate(6),
        const Radius.circular(8),
      );
      canvas
        ..drawRRect(rect, Paint()..color = color.withValues(alpha: 0.25))
        ..drawRRect(rect, Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    }
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) => oldDelegate.highlights != highlights;
}
