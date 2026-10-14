import 'dart:async';

import 'package:allergen_scanner/app/app.dart';
import 'package:allergen_scanner/core/preferences_provider.dart';
import 'package:allergen_scanner/features/history/domain/history_repository.dart';
import 'package:allergen_scanner/features/history/presentation/history_providers.dart';
import 'package:allergen_scanner/features/paywall/presentation/pro_controller.dart';
import 'package:allergen_scanner/features/onboarding/data/speech_service.dart';
import 'package:allergen_scanner/features/onboarding/presentation/onboarding_providers.dart';
import 'package:allergen_scanner/features/profiles/domain/profile.dart';
import 'package:allergen_scanner/features/profiles/presentation/profiles_providers.dart';
import 'package:allergen_scanner/features/scan/domain/allergen_matcher.dart';
import 'package:allergen_scanner/features/scan/domain/camera_permission_repository.dart';
import 'package:allergen_scanner/features/scan/domain/scan_report.dart';
import 'package:allergen_scanner/features/scan/presentation/ocr_providers.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_controller.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_quota.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_session.dart';
import 'package:allergen_scanner/features/scan/presentation/scanner_screen.dart';
import 'package:core_billing/core_billing.dart';
import 'package:core_i18n/core_i18n.dart';
import 'package:flutter/widgets.dart';
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

class InMemoryHistoryRepository implements HistoryRepository {
  InMemoryHistoryRepository([List<ScanReport> initial = const []]) : _reports = [...initial] {
    _nextId = _reports.fold(0, (max, r) => (r.id ?? 0) > max ? r.id! : max) + 1;
  }

  final List<ScanReport> _reports;
  late int _nextId;
  final _changes = StreamController<List<ScanReport>>.broadcast();

  List<ScanReport> get reports => List.unmodifiable(_reports);

  List<ScanReport> _sorted() => [..._reports]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _emit() => _changes.add(_sorted());

  @override
  Stream<List<ScanReport>> watchAll() async* {
    yield _sorted();
    yield* _changes.stream;
  }

  @override
  Future<ScanReport> save(ScanReport report) async {
    final id = report.id;
    if (id != null) {
      await rename(id, report.productName ?? '');
      return report;
    }
    final saved = report.copyWith(id: _nextId++);
    _reports.add(saved);
    _emit();
    return saved;
  }

  @override
  Future<void> rename(int id, String productName) async {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index >= 0) _reports[index] = _reports[index].copyWith(productName: productName);
    _emit();
  }

  @override
  Future<void> delete(int id) async {
    _reports.removeWhere((r) => r.id == id);
    _emit();
  }

  @override
  Future<int> deleteOlderThan(DateTime limit) async {
    final before = _reports.length;
    _reports.removeWhere((r) => r.createdAt.isBefore(limit));
    if (before != _reports.length) _emit();
    return before - _reports.length;
  }
}

class NoModels implements TranslationModelRepository {
  @override
  Future<bool> isDownloaded(AppLanguage language) async => false;

  @override
  Future<void> download(AppLanguage language) async {}

  @override
  Future<void> delete(AppLanguage language) async {}
}

class FakePermissions implements CameraPermissionRepository {
  FakePermissions([this.result = CameraPermission.granted]);

  CameraPermission result;
  int settingsOpened = 0;

  @override
  Future<CameraPermission> request() async => result;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

class FakeSpeech implements SpeechService {
  FakeSpeech({this.words = '', this.failure});

  final String words;
  final SpeechFailure? failure;
  void Function(String words, bool isFinal)? _onWords;

  @override
  Future<bool> initialize({required void Function(SpeechFailure failure) onFailure}) async {
    final problem = failure;
    if (problem != null) {
      onFailure(problem);
      return false;
    }
    return true;
  }

  @override
  Future<void> listen({required String localeId, required void Function(String words, bool isFinal) onWords}) async {
    _onWords = onWords;
    onWords(words, false);
  }

  @override
  Future<void> stop() async => _onWords?.call(words, true);

  @override
  Future<void> cancel() async {}
}

const defaultTestProfile = Profile(id: 1, name: 'Yo', allergenIds: {'milk', 'eggs', 'gluten'});

final testNow = DateTime(2026, 10, 13, 18, 20);

Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  String language = 'es',
  bool onboarded = true,
  bool? pro = false,
  BillingService? billing,
  double textScale = 1,
  InMemoryProfileRepository? profiles,
  InMemoryHistoryRepository? history,
  FakePermissions? permissions,
  SpeechService? speech,
  Map<String, Object> preferences = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'interface_language': language,
    'onboarding_done': onboarded,
    if (onboarded) 'active_profile_id': 1,
    ...preferences,
  });
  final prefs = await SharedPreferences.getInstance();
  final profileRepository = profiles ?? InMemoryProfileRepository(onboarded ? [defaultTestProfile] : []);
  await tester.binding.setSurfaceSize(const Size(430, 932));
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.binding.setSurfaceSize(null);
    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        historyRepositoryProvider.overrideWithValue(history ?? InMemoryHistoryRepository()),
        translationModelRepositoryProvider.overrideWithValue(NoModels()),
        cameraPermissionRepositoryProvider.overrideWithValue(permissions ?? FakePermissions()),
        cameraListProvider.overrideWithValue(() async => const []),
        speechServiceProvider.overrideWithValue(speech ?? FakeSpeech()),
        matchRunnerProvider.overrideWithValue((dictionary, streams) async => AllergenMatcher(dictionary).match(streams)),
        clockProvider.overrideWithValue(() => testNow),
        if (pro != null) isProProvider.overrideWithValue(pro),
        billingServiceProvider.overrideWithValue(billing ?? const UnavailableBillingService()),
        ...overrides,
      ],
      child: const AllergenScannerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

class FakeBilling implements BillingService {
  FakeBilling({this.owned = false, this.purchaseOutcome = PurchaseOutcome.purchased, this.restoreOutcome = RestoreOutcome.nothingToRestore});

  bool owned;
  PurchaseOutcome purchaseOutcome;
  RestoreOutcome restoreOutcome;
  final _changes = StreamController<bool>.broadcast();

  @override
  bool get isConfigured => true;

  @override
  Future<void> configure() async {}

  @override
  Future<bool> isPro() async => owned;

  @override
  Stream<bool> watchPro() => _changes.stream;

  @override
  Future<ProOffer?> loadOffer() async => const ProOffer(priceString: 'S/ 14.90');

  @override
  Future<PurchaseOutcome> purchasePro() async {
    if (purchaseOutcome == PurchaseOutcome.purchased) owned = true;
    return purchaseOutcome;
  }

  @override
  Future<RestoreOutcome> restore() async {
    if (restoreOutcome == RestoreOutcome.restored) owned = true;
    return restoreOutcome;
  }
}
