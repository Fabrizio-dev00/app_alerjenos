import 'dart:async';

import 'package:allergen_scanner/app/app.dart';
import 'package:allergen_scanner/core/preferences_provider.dart';
import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:allergen_scanner/features/profiles/presentation/profiles_providers.dart';
import 'package:allergen_scanner/features/scan/presentation/ocr_providers.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository([List<Profile> initial = const []]) : _profiles = [...initial] {
    _nextId = _profiles.fold(0, (max, p) => p.id > max ? p.id : max) + 1;
  }

  final List<Profile> _profiles;
  late int _nextId;
  final _changes = StreamController<List<Profile>>.broadcast();

  List<Profile> get profiles => List.unmodifiable(_profiles);

  void _emit() => _changes.add(List.unmodifiable(_profiles));

  @override
  Stream<List<Profile>> watchAll() async* {
    yield List.unmodifiable(_profiles);
    yield* _changes.stream;
  }

  @override
  Future<Profile> create({required String name, required Set<String> allergenIds}) async {
    final profile = Profile(id: _nextId++, name: name.trim(), allergenIds: allergenIds);
    _profiles.add(profile);
    _emit();
    return profile;
  }

  @override
  Future<void> update(Profile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) _profiles[index] = profile;
    _emit();
  }

  @override
  Future<void> delete(int id) async {
    _profiles.removeWhere((p) => p.id == id);
    _emit();
  }
}

class _NoModels implements TranslationModelRepository {
  @override
  Future<bool> isDownloaded(AppLanguage language) async => false;

  @override
  Future<void> download(AppLanguage language) async {}

  @override
  Future<void> delete(AppLanguage language) async {}
}

const defaultTestProfile = Profile(id: 1, name: 'Yo', allergenIds: {'milk', 'eggs', 'gluten'});

Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  String language = 'es',
  bool onboarded = true,
  InMemoryProfileRepository? profiles,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'interface_language': language,
    'onboarding_done': onboarded,
    if (onboarded) 'active_profile_id': 1,
  });
  final preferences = await SharedPreferences.getInstance();
  final repository = profiles ?? InMemoryProfileRepository(onboarded ? [defaultTestProfile] : []);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        profileRepositoryProvider.overrideWithValue(repository),
        translationModelRepositoryProvider.overrideWithValue(_NoModels()),
        ...overrides,
      ],
      child: const AllergenScannerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return preferences;
}
