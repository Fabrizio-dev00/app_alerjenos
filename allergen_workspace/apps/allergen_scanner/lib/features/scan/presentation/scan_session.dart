import 'dart:isolate';

import 'package:core_ocr/core_ocr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/allergens/allergen_dictionary.dart';
import '../../../core/allergens/allergen_dictionary_provider.dart';
import '../../../core/telemetry/telemetry.dart';
import '../../history/presentation/history_providers.dart';
import '../../profiles/presentation/profiles_providers.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/allergen_matcher.dart';
import '../domain/label_analysis.dart';
import '../domain/scan_report.dart';
import '../domain/scan_report_builder.dart';
import '../domain/token_stream.dart';
import 'ocr_providers.dart';
import 'scan_quota.dart';

typedef MatchRunner = Future<List<AllergenFinding>> Function(AllergenDictionary dictionary, List<TokenStream> streams);

final matchRunnerProvider = Provider<MatchRunner>(
  (ref) => (dictionary, streams) => Isolate.run(() => AllergenMatcher(dictionary).match(streams)),
);

enum ScanStage { reading, translating, matching, done, failed }

class ScanSession {
  const ScanSession({required this.stage, this.analysis, this.report});

  final ScanStage stage;
  final LabelAnalysis? analysis;
  final ScanReport? report;

  ScanSession copyWith({ScanStage? stage, LabelAnalysis? analysis, ScanReport? report}) => ScanSession(
        stage: stage ?? this.stage,
        analysis: analysis ?? this.analysis,
        report: report ?? this.report,
      );
}

final scanSessionProvider = NotifierProvider.autoDispose.family<ScanSessionController, ScanSession, String>(
  ScanSessionController.new,
);

class ScanSessionController extends Notifier<ScanSession> {
  ScanSessionController(this.imagePath);

  final String imagePath;

  @override
  ScanSession build() {
    Future.microtask(_run);
    return const ScanSession(stage: ScanStage.reading);
  }

  void _set(ScanSession next) {
    if (ref.mounted) state = next;
  }

  Future<void> _run() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) {
      _set(const ScanSession(stage: ScanStage.failed));
      return;
    }

    final OcrResult ocr;
    try {
      ocr = await ref.read(textRecognizerProvider).recognize(imagePath);
    } on OcrException {
      _set(const ScanSession(stage: ScanStage.failed));
      return;
    }
    if (!ref.mounted) return;
    _set(state.copyWith(stage: ScanStage.translating));

    final analyze = AnalyzeLabel(
      detector: ref.read(languageDetectorProvider),
      translator: ref.read(translationServiceProvider),
    );
    final analysis = await analyze(ocr, target: ref.read(scanTargetLanguageProvider));
    if (!ref.mounted) return;
    _set(state.copyWith(stage: ScanStage.matching, analysis: analysis));

    final dictionary = await ref.read(allergenDictionaryProvider.future);
    final streams = [
      TokenStream.fromOcr(ocr),
      if (analysis.translatedBlocks case final translated?) TokenStream.fromTranslatedBlocks(translated),
    ];
    final findings = await ref.read(matchRunnerProvider)(dictionary, streams);
    if (!ref.mounted) return;

    var report = ScanReportBuilder.build(
      analysis: analysis,
      findings: findings,
      profile: profile,
      imagePath: imagePath,
      now: ref.read(clockProvider)(),
    );
    final telemetry = ref.read(telemetryProvider);
    if (report.verdict == ScanVerdict.unreadable) {
      telemetry.log(TelemetryEvent.scanUnreadable);
    } else {
      telemetry.log(TelemetryEvent.scanCompleted, {
        'verdict': report.verdict.name,
        'translated': report.wasTranslated ? 1 : 0,
        'source_language': report.sourceLanguage ?? 'unknown',
      });
    }
    if (report.verdict != ScanVerdict.unreadable) {
      await ref.read(scanQuotaProvider.notifier).consume();
      if (ref.read(appSettingsProvider).saveHistory) {
        report = await ref.read(historyRepositoryProvider).save(report);
      }
    }
    _set(state.copyWith(stage: ScanStage.done, report: report));
  }
}
