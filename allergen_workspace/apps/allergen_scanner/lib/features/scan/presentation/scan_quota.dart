import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences_provider.dart';
import '../../profiles/presentation/profiles_providers.dart';

class ScanQuota {
  const ScanQuota({required this.used, required this.unlimited});

  static const dailyLimit = 5;

  final int used;
  final bool unlimited;

  int get remaining => unlimited ? dailyLimit : (dailyLimit - used).clamp(0, dailyLimit);

  bool get exhausted => !unlimited && remaining == 0;
}

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final scanQuotaProvider = NotifierProvider<ScanQuotaController, ScanQuota>(ScanQuotaController.new);

class ScanQuotaController extends Notifier<ScanQuota> {
  static const _dayKey = 'quota_day';
  static const _countKey = 'quota_count';

  String _today() {
    final now = ref.read(clockProvider)();
    return '${now.year}-${now.month}-${now.day}';
  }

  @override
  ScanQuota build() {
    final unlimited = ref.watch(isProProvider);
    final preferences = ref.read(sharedPreferencesProvider);
    final used = preferences.getString(_dayKey) == _today() ? preferences.getInt(_countKey) ?? 0 : 0;
    return ScanQuota(used: used, unlimited: unlimited);
  }

  Future<void> consume() async {
    if (state.unlimited) return;
    final preferences = ref.read(sharedPreferencesProvider);
    final today = _today();
    final used = (preferences.getString(_dayKey) == today ? preferences.getInt(_countKey) ?? 0 : 0) + 1;
    await preferences.setString(_dayKey, today);
    await preferences.setInt(_countKey, used);
    state = ScanQuota(used: used, unlimited: false);
  }
}
