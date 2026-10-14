import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../profiles/presentation/profiles_providers.dart';
import '../../scan/domain/scan_report.dart';
import '../../scan/presentation/scan_quota.dart';
import '../data/drift_history_repository.dart';
import '../domain/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => DriftHistoryRepository(
    ref.watch(appDatabaseProvider),
    photosDirectory: () async => Directory('${(await getApplicationSupportDirectory()).path}/scans'),
  ),
);

final historyProvider = StreamProvider<List<ScanReport>>(
  (ref) => ref.watch(historyRepositoryProvider).watchAll(),
);

final historyRetentionProvider = FutureProvider<int>((ref) async {
  if (ref.watch(isProProvider)) return 0;
  final now = ref.read(clockProvider)();
  return ref.read(historyRepositoryProvider).deleteOlderThan(
        now.subtract(const Duration(days: HistoryRetention.freeDays)),
      );
});
