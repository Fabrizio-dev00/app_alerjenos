import '../../scan/domain/scan_report.dart';

abstract interface class HistoryRepository {
  Stream<List<ScanReport>> watchAll();

  Future<ScanReport> save(ScanReport report);

  Future<void> rename(int id, String productName);

  Future<void> delete(int id);

  Future<int> deleteOlderThan(DateTime limit);
}

abstract final class HistoryRetention {
  static const freeDays = 30;
}
