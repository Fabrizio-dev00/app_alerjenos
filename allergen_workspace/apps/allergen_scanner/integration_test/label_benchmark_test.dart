import 'dart:convert';
import 'dart:io';

import 'package:allergen_scanner/core/text/fuzzy_matcher.dart';
import 'package:allergen_scanner/features/scan/domain/ingredient_section.dart';
import 'package:core_ocr/core_ocr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _LabelCase {
  _LabelCase.fromJson(Map<String, dynamic> json)
      : file = json['file'] as String,
        language = json['language'] as String? ?? '',
        mustFind = [for (final term in json['mustFind'] as List) term as String];

  final String file;
  final String language;
  final List<String> mustFind;
}

class _Reading {
  _Reading({required this.found, required this.missing, required this.sectionFound, required this.millis});

  final List<String> found;
  final List<String> missing;
  final bool sectionFound;
  final int millis;

  Map<String, Object> toJson() => {
        'found': found,
        'missing': missing,
        'sectionFound': sectionFound,
        'millis': millis,
      };
}

Future<_Reading> _read(TextRecognizerService recognizer, String path, List<String> mustFind) async {
  final watch = Stopwatch()..start();
  final ocr = await recognizer.recognize(path);
  watch.stop();
  final found = [for (final term in mustFind) if (FuzzyMatcher.containsPhrase(ocr.text, term)) term];
  return _Reading(
    found: found,
    missing: [for (final term in mustFind) if (!found.contains(term)) term],
    sectionFound: IngredientSectionLocator.locate(ocr).found,
    millis: watch.elapsedMilliseconds,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('banco de etiquetas reales: foto normal contra contraste mejorado', (tester) async {
    final dir = Directory('/storage/emulated/0/Android/data/dev.fabrizio.allergen_scanner/files/labels');
    final manifest = File('${dir.path}/labels.json');
    expect(manifest.existsSync(), isTrue, reason: 'Sube las etiquetas con tool/run_label_benchmark.ps1');

    final cases = [
      for (final entry in jsonDecode(manifest.readAsStringSync()) as List)
        _LabelCase.fromJson(entry as Map<String, dynamic>),
    ];
    final recognizer = MlKitTextRecognizerService();
    final report = <Map<String, Object>>[];
    var termsTotal = 0;
    var rawFound = 0;
    var enhancedFound = 0;
    var rawSections = 0;
    var enhancedSections = 0;

    for (final label in cases) {
      final path = '${dir.path}/images/${label.file}';
      if (!File(path).existsSync()) {
        report.add({'file': label.file, 'error': 'imagen no encontrada'});
        continue;
      }
      final raw = await _read(recognizer, path, label.mustFind);
      final enhancedPath = await ImagePreprocessor.enhanceContrast(path);
      final enhanced = await _read(recognizer, enhancedPath, label.mustFind);
      File(enhancedPath).deleteSync();

      termsTotal += label.mustFind.length;
      rawFound += raw.found.length;
      enhancedFound += enhanced.found.length;
      if (raw.sectionFound) rawSections++;
      if (enhanced.sectionFound) enhancedSections++;
      report.add({
        'file': label.file,
        'language': label.language,
        'raw': raw.toJson(),
        'enhanced': enhanced.toJson(),
      });
      debugPrint('ETIQUETA ${label.file} [${label.language}] '
          'normal ${raw.found.length}/${label.mustFind.length} faltan ${raw.missing} | '
          'contraste ${enhanced.found.length}/${label.mustFind.length} faltan ${enhanced.missing}');
    }
    await recognizer.close();

    final summary = {
      'labels': cases.length,
      'terms': termsTotal,
      'rawFound': rawFound,
      'enhancedFound': enhancedFound,
      'rawSectionsFound': rawSections,
      'enhancedSectionsFound': enhancedSections,
    };
    File('${dir.path}/report.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'summary': summary, 'labels': report}),
    );
    debugPrint('RESUMEN términos encontrados: normal $rawFound/$termsTotal, '
        'contraste $enhancedFound/$termsTotal | sección de ingredientes: '
        'normal $rawSections/${cases.length}, contraste $enhancedSections/${cases.length}');

    expect(cases, isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
