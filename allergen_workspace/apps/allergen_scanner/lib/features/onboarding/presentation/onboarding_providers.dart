import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/allergens/allergen_dictionary_provider.dart';
import '../data/speech_service.dart';
import '../domain/allergen_phrase_parser.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = DeviceSpeechService();
  ref.onDispose(service.cancel);
  return service;
});

final allergenPhraseParserProvider = FutureProvider<AllergenPhraseParser>(
  (ref) async => AllergenPhraseParser(await ref.watch(allergenDictionaryProvider.future)),
);

class OnboardingDraft {
  const OnboardingDraft({this.allergenIds = const {}, this.transcript = '', this.editingProfileId});

  final Set<String> allergenIds;
  final String transcript;
  final int? editingProfileId;

  OnboardingDraft copyWith({Set<String>? allergenIds, String? transcript}) => OnboardingDraft(
    allergenIds: allergenIds ?? this.allergenIds,
    transcript: transcript ?? this.transcript,
    editingProfileId: editingProfileId,
  );
}

final onboardingDraftProvider = NotifierProvider<OnboardingDraftController, OnboardingDraft>(
  OnboardingDraftController.new,
);

class OnboardingDraftController extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setAllergens(Set<String> allergenIds) => state = state.copyWith(allergenIds: allergenIds);

  void setTranscript(String transcript, Set<String> allergenIds) =>
      state = state.copyWith(transcript: transcript, allergenIds: allergenIds);

  void reset() => state = const OnboardingDraft();
}
