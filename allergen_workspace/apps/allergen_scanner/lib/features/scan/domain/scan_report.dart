import 'package:core_ocr/core_ocr.dart';

import '../../profiles/domain/allergen_choice.dart';
import 'allergen_matcher.dart';

enum ScanVerdict { contains, mayContain, notDetected, unreadable }

class AllergenHit {
  const AllergenHit({
    required this.choice,
    required this.level,
    required this.possible,
    this.original,
    this.translated,
  });

  factory AllergenHit.fromJson(Map<String, dynamic> json) => AllergenHit(
        choice: AllergenChoice.values.byName(json['choice'] as String),
        level: MatchLevel.values.byName(json['level'] as String),
        possible: json['possible'] as bool? ?? false,
        original: json['original'] as String?,
        translated: json['translated'] as String?,
      );

  final AllergenChoice choice;
  final MatchLevel level;
  final bool possible;
  final String? original;
  final String? translated;

  Map<String, Object?> toJson() => {
        'choice': choice.name,
        'level': level.name,
        'possible': possible,
        'original': original,
        'translated': translated,
      };
}

class HighlightBox {
  const HighlightBox({required this.box, required this.level});

  factory HighlightBox.fromJson(Map<String, dynamic> json) => HighlightBox(
        box: OcrBox(
          left: (json['l'] as num).toDouble(),
          top: (json['t'] as num).toDouble(),
          width: (json['w'] as num).toDouble(),
          height: (json['h'] as num).toDouble(),
        ),
        level: MatchLevel.values.byName(json['level'] as String),
      );

  final OcrBox box;
  final MatchLevel level;

  Map<String, Object?> toJson() => {
        'l': box.left,
        't': box.top,
        'w': box.width,
        'h': box.height,
        'level': level.name,
      };
}

class ScanReport {
  const ScanReport({
    required this.createdAt,
    required this.imagePath,
    required this.profileName,
    required this.verdict,
    required this.hits,
    required this.targetLanguage,
    required this.originalSection,
    required this.ingredientCount,
    required this.imageWidth,
    required this.imageHeight,
    this.id,
    this.sourceLanguage,
    this.translatedSection,
    this.highlights = const [],
    this.productName,
    this.suggestedName = '',
  });

  factory ScanReport.fromJson(Map<String, dynamic> json, {int? id, String? productName}) => ScanReport(
        id: id,
        createdAt: DateTime.parse(json['createdAt'] as String),
        imagePath: json['imagePath'] as String,
        profileName: json['profileName'] as String,
        verdict: ScanVerdict.values.byName(json['verdict'] as String),
        hits: [for (final hit in json['hits'] as List) AllergenHit.fromJson(hit as Map<String, dynamic>)],
        sourceLanguage: json['sourceLanguage'] as String?,
        targetLanguage: json['targetLanguage'] as String,
        originalSection: json['originalSection'] as String,
        translatedSection: json['translatedSection'] as String?,
        ingredientCount: json['ingredientCount'] as int,
        imageWidth: (json['imageWidth'] as num).toDouble(),
        imageHeight: (json['imageHeight'] as num).toDouble(),
        highlights: [
          for (final box in json['highlights'] as List? ?? const []) HighlightBox.fromJson(box as Map<String, dynamic>),
        ],
        productName: productName ?? json['productName'] as String?,
        suggestedName: json['suggestedName'] as String? ?? '',
      );

  final int? id;
  final DateTime createdAt;
  final String imagePath;
  final String profileName;
  final ScanVerdict verdict;
  final List<AllergenHit> hits;
  final String? sourceLanguage;
  final String targetLanguage;
  final String originalSection;
  final String? translatedSection;
  final int ingredientCount;
  final double imageWidth;
  final double imageHeight;
  final List<HighlightBox> highlights;
  final String? productName;
  final String suggestedName;

  bool get wasTranslated => translatedSection != null && sourceLanguage != targetLanguage;

  List<AllergenHit> get containsHits => [for (final hit in hits) if (hit.level == MatchLevel.contains) hit];

  List<AllergenHit> get traceHits => [for (final hit in hits) if (hit.level == MatchLevel.mayContain) hit];

  ScanReport copyWith({int? id, String? productName, String? imagePath}) => ScanReport(
        id: id ?? this.id,
        createdAt: createdAt,
        imagePath: imagePath ?? this.imagePath,
        profileName: profileName,
        verdict: verdict,
        hits: hits,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        originalSection: originalSection,
        translatedSection: translatedSection,
        ingredientCount: ingredientCount,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        highlights: highlights,
        productName: productName ?? this.productName,
        suggestedName: suggestedName,
      );

  Map<String, Object?> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'profileName': profileName,
        'verdict': verdict.name,
        'hits': [for (final hit in hits) hit.toJson()],
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'originalSection': originalSection,
        'translatedSection': translatedSection,
        'ingredientCount': ingredientCount,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'highlights': [for (final box in highlights) box.toJson()],
        'productName': productName,
        'suggestedName': suggestedName,
      };
}
