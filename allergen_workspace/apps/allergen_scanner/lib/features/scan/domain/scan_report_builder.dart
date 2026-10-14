import 'package:core_ocr/core_ocr.dart';

import '../../../core/text/text_normalizer.dart';
import '../../profiles/domain/allergen_choice.dart';
import '../../profiles/domain/profile.dart';
import 'allergen_matcher.dart';
import 'ingredient_splitter.dart';
import 'label_analysis.dart';
import 'scan_report.dart';
import 'token_stream.dart';

abstract final class ScanReportBuilder {
  static const minimumSectionTokens = 3;

  static ScanReport build({
    required LabelAnalysis analysis,
    required List<AllergenFinding> findings,
    required Profile profile,
    required String imagePath,
    required DateTime now,
  }) {
    final byId = {for (final finding in findings) finding.allergen.id: finding};
    final hits = <AllergenHit>[];
    final highlights = <HighlightBox>[];

    for (final choice in AllergenChoice.values) {
      final ids = [for (final id in choice.allergenIds) if (profile.allergenIds.contains(id)) id];
      final evidence = [
        for (final id in ids)
          if (byId[id] case final finding?) ...finding.evidence,
      ];
      if (evidence.isEmpty) continue;

      final level = evidence.any((e) => e.level == MatchLevel.contains) ? MatchLevel.contains : MatchLevel.mayContain;
      final relevant = [for (final e in evidence) if (e.level == level) e];
      String? first(TextSource source) {
        String? best;
        for (final e in relevant) {
          if (e.source != source || e.matchedText.isEmpty) continue;
          if (best == null || e.matchedText.length > best.length) best = e.matchedText;
        }
        return best;
      }

      hits.add(AllergenHit(
        choice: choice,
        level: level,
        possible: relevant.every((e) => e.isPossible),
        original: first(TextSource.original),
        translated: first(TextSource.translated),
      ));
      for (final e in relevant) {
        if (e.source != TextSource.original) continue;
        for (final box in e.boxes) {
          highlights.add(HighlightBox(box: box, level: level));
        }
      }
    }

    final section = analysis.section;
    final sectionTokens = TextNormalizer.tokens(section.text).length;
    final readable = section.found && sectionTokens >= minimumSectionTokens;

    final ScanVerdict verdict;
    if (hits.any((hit) => hit.level == MatchLevel.contains)) {
      verdict = ScanVerdict.contains;
    } else if (hits.isNotEmpty) {
      verdict = ScanVerdict.mayContain;
    } else if (readable) {
      verdict = ScanVerdict.notDetected;
    } else {
      verdict = ScanVerdict.unreadable;
    }

    final translated = analysis.outcome == TranslationOutcome.translated;
    return ScanReport(
      createdAt: now,
      imagePath: imagePath,
      profileName: profile.name,
      verdict: verdict,
      hits: hits,
      sourceLanguage: analysis.detectedLanguage?.code ?? analysis.detectedCode,
      targetLanguage: analysis.target.code,
      originalSection: section.found ? section.text : analysis.ocr.text,
      translatedSection: translated ? analysis.sectionText(translated: true) : null,
      ingredientCount: section.found ? IngredientSplitter.split(section.text).length : 0,
      imageWidth: analysis.ocr.imageWidth,
      imageHeight: analysis.ocr.imageHeight,
      highlights: highlights,
      suggestedName: suggestName(analysis.ocr, section.blockIndices.toSet()),
    );
  }

  static String suggestName(OcrResult ocr, Set<int> excludedBlocks) {
    OcrLine? best;
    for (var i = 0; i < ocr.blocks.length; i++) {
      if (excludedBlocks.contains(i)) continue;
      for (final line in ocr.blocks[i].lines) {
        final text = line.text.trim();
        final letters = text.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length;
        if (text.length < 3 || text.length > 40 || letters < 3) continue;
        if (best == null || line.box.height > best.box.height) best = line;
      }
    }
    return best?.text.trim() ?? '';
  }
}
