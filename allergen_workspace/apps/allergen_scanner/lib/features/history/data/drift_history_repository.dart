import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../scan/domain/scan_report.dart';
import '../domain/history_repository.dart';

class DriftHistoryRepository implements HistoryRepository {
  DriftHistoryRepository(this._db, {required this.photosDirectory});

  final AppDatabase _db;
  final Future<Directory> Function() photosDirectory;

  static ScanReport _toReport(ScanRow row) => ScanReport.fromJson(
        jsonDecode(row.report) as Map<String, dynamic>,
        id: row.id,
        productName: row.productName,
      );

  @override
  Stream<List<ScanReport>> watchAll() {
    final query = _db.select(_db.scans)..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().map((rows) => rows.map(_toReport).toList());
  }

  Future<String> _keepPhoto(String path) async {
    final source = File(path);
    if (!source.existsSync()) return path;
    final directory = await photosDirectory();
    if (!directory.existsSync()) directory.createSync(recursive: true);
    if (source.parent.path == directory.path) return path;
    final name = 'scan_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return (await source.copy('${directory.path}${Platform.pathSeparator}$name')).path;
  }

  @override
  Future<ScanReport> save(ScanReport report) async {
    final existing = report.id;
    if (existing != null) {
      await rename(existing, report.productName ?? '');
      return report;
    }
    final kept = report.copyWith(imagePath: await _keepPhoto(report.imagePath));
    final id = await _db.into(_db.scans).insert(ScansCompanion.insert(
          createdAt: kept.createdAt,
          verdict: kept.verdict.name,
          productName: Value(kept.productName),
          languageCode: Value(kept.sourceLanguage),
          profileName: kept.profileName,
          report: jsonEncode(kept.toJson()),
        ));
    return kept.copyWith(id: id);
  }

  @override
  Future<void> rename(int id, String productName) async {
    final name = productName.trim();
    await (_db.update(_db.scans)..where((s) => s.id.equals(id)))
        .write(ScansCompanion(productName: Value(name.isEmpty ? null : name)));
  }

  @override
  Future<void> delete(int id) async {
    final row = await (_db.select(_db.scans)..where((s) => s.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.delete(_db.scans)..where((s) => s.id.equals(id))).go();
    _deletePhoto(_toReport(row).imagePath);
  }

  @override
  Future<int> deleteOlderThan(DateTime limit) async {
    final old = await (_db.select(_db.scans)..where((s) => s.createdAt.isSmallerThanValue(limit))).get();
    for (final row in old) {
      _deletePhoto(_toReport(row).imagePath);
    }
    return (_db.delete(_db.scans)..where((s) => s.createdAt.isSmallerThanValue(limit))).go();
  }

  void _deletePhoto(String path) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
