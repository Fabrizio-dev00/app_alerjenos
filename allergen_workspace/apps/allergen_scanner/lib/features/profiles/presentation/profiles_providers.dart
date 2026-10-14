import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/preferences_provider.dart';
import '../../paywall/presentation/pro_controller.dart';
import '../data/drift_profile_repository.dart';
import '../domain/profile.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(ref.watch(appDatabaseProvider)),
);

final profilesProvider = StreamProvider<List<Profile>>(
  (ref) => ref.watch(profileRepositoryProvider).watchAll(),
);

final isProProvider = Provider<bool>((ref) => ref.watch(proControllerProvider).isPro);

final canAddProfileProvider = Provider<bool>((ref) {
  final count = ref.watch(profilesProvider).value?.length ?? 0;
  final limit = ref.watch(isProProvider) ? ProfileLimits.pro : ProfileLimits.free;
  return count < limit;
});

final activeProfileIdProvider = NotifierProvider<ActiveProfileIdController, int?>(
  ActiveProfileIdController.new,
);

class ActiveProfileIdController extends Notifier<int?> {
  static const _key = 'active_profile_id';

  @override
  int? build() => ref.read(sharedPreferencesProvider).getInt(_key);

  Future<void> select(int id) async {
    await ref.read(sharedPreferencesProvider).setInt(_key, id);
    state = id;
  }
}

final activeProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const [];
  if (profiles.isEmpty) return null;
  final id = ref.watch(activeProfileIdProvider);
  return profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
});

final onboardingDoneProvider = NotifierProvider<OnboardingDoneController, bool>(
  OnboardingDoneController.new,
);

class OnboardingDoneController extends Notifier<bool> {
  static const _key = 'onboarding_done';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete({required String profileName, required Set<String> allergenIds}) async {
    final profile = await ref.read(profileRepositoryProvider).create(
          name: profileName,
          allergenIds: allergenIds,
        );
    await ref.read(activeProfileIdProvider.notifier).select(profile.id);
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}
