import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechFailure { unavailable, offlineUnsupported, denied, noMatch, other }

abstract interface class SpeechService {
  Future<bool> initialize({required void Function(SpeechFailure failure) onFailure});

  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onWords,
  });

  Future<void> stop();

  Future<void> cancel();
}

class DeviceSpeechService implements SpeechService {
  final SpeechToText _speech = SpeechToText();
  void Function(SpeechFailure failure)? _onFailure;

  static SpeechFailure _classify(SpeechRecognitionError error) {
    final message = error.errorMsg.toLowerCase();
    if (message.contains('language') || message.contains('server') || message.contains('network')) {
      return SpeechFailure.offlineUnsupported;
    }
    if (message.contains('permission') || message.contains('insufficient')) return SpeechFailure.denied;
    if (message.contains('no_match') || message.contains('speech_timeout')) return SpeechFailure.noMatch;
    return SpeechFailure.other;
  }

  @override
  Future<bool> initialize({required void Function(SpeechFailure failure) onFailure}) async {
    _onFailure = onFailure;
    final available = await _speech.initialize(onError: (error) => _onFailure?.call(_classify(error)));
    if (!available) onFailure(await _speech.hasPermission ? SpeechFailure.unavailable : SpeechFailure.denied);
    return available;
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onWords,
  }) async {
    final locales = await _speech.locales();
    final match = locales.where((l) => l.localeId.toLowerCase().startsWith(localeId.toLowerCase()));
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) => onWords(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        onDevice: true,
        partialResults: true,
        cancelOnError: true,
        localeId: match.isEmpty ? null : match.first.localeId,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
