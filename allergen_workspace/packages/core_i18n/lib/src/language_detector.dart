import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

abstract interface class LanguageDetector {
  Future<String?> detect(String text);

  Future<void> close();
}

class MlKitLanguageDetector implements LanguageDetector {
  MlKitLanguageDetector({double confidenceThreshold = 0.5})
      : _identifier = LanguageIdentifier(confidenceThreshold: confidenceThreshold);

  static const _undetermined = 'und';

  final LanguageIdentifier _identifier;

  @override
  Future<String?> detect(String text) async {
    if (text.trim().isEmpty) return null;
    final code = (await _identifier.identifyLanguage(text)).toLowerCase();
    return code == _undetermined ? null : code;
  }

  @override
  Future<void> close() => _identifier.close();
}
