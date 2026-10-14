import 'dart:io';

import 'package:allergen_scanner/core/database/app_database.dart';
import 'package:allergen_scanner/features/history/data/drift_history_repository.dart';
import 'package:allergen_scanner/features/profiles/domain/allergen_choice.dart';
import 'package:allergen_scanner/features/scan/domain/allergen_matcher.dart';
import 'package:allergen_scanner/features/scan/domain/scan_report.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'helpers/pump_app.dart';

ScanReport report({required DateTime at, ScanVerdict verdict = ScanVerdict.contains, String? name, String path = '/missing.jpg'}) =>
    ScanReport(
      createdAt: at,
      imagePath: path,
      profileName: 'Yo',
      verdict: verdict,
      hits: [
        if (verdict == ScanVerdict.contains)
          const AllergenHit(choice: AllergenChoice.milk, level: MatchLevel.contains, possible: false, original: 'beurre'),
      ],
      sourceLanguage: 'fr',
      targetLanguage: 'es',
      originalSection: 'Ingrédients : beurre',
      ingredientCount: 1,
      imageWidth: 100,
      imageHeight: 100,
      productName: name,
    );

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('DriftHistoryRepository', () {
    late AppDatabase db;
    late Directory photos;
    late DriftHistoryRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      photos = Directory.systemTemp.createTempSync('scans');
      repository = DriftHistoryRepository(db, photosDirectory: () async => photos);
    });

    tearDown(() async {
      await db.close();
      if (photos.existsSync()) photos.deleteSync(recursive: true);
    });

    test('guarda, ordena del más nuevo al más viejo y copia la foto', () async {
      final source = File('${Directory.systemTemp.path}${Platform.pathSeparator}label_${DateTime.now().microsecondsSinceEpoch}.jpg')
        ..writeAsBytesSync([1, 2, 3]);
      await repository.save(report(at: DateTime(2026, 10, 12), name: 'Pasta'));
      final saved = await repository.save(report(at: DateTime(2026, 10, 13), path: source.path));

      final all = await repository.watchAll().first;
      expect(all.map((r) => r.id), [saved.id, isNotNull]);
      expect(all.last.productName, 'Pasta');
      expect(saved.imagePath, startsWith(photos.path));
      expect(File(saved.imagePath).existsSync(), isTrue);
      expect(all.first.hits.single.original, 'beurre');
      source.deleteSync();
    });

    test('renombrar y borrar', () async {
      final saved = await repository.save(report(at: DateTime(2026, 10, 13)));

      await repository.rename(saved.id!, '  Galletas  ');
      expect((await repository.watchAll().first).single.productName, 'Galletas');

      await repository.delete(saved.id!);
      expect(await repository.watchAll().first, isEmpty);
    });

    test('borra lo más viejo que el límite de 30 días del plan gratis', () async {
      await repository.save(report(at: DateTime(2026, 8, 1)));
      await repository.save(report(at: DateTime(2026, 10, 1)));

      final removed = await repository.deleteOlderThan(DateTime(2026, 9, 13));

      expect(removed, 1);
      expect((await repository.watchAll().first).single.createdAt, DateTime(2026, 10, 1));
    });
  });

  test('la migración de la versión 1 a la 2 conserva los perfiles y crea el historial', () async {
    final raw = sqlite3.openInMemory();
    raw.execute(
      'CREATE TABLE profiles (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, '
      "allergens TEXT NOT NULL DEFAULT '', created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)))",
    );
    raw.execute("INSERT INTO profiles (name, allergens) VALUES ('Yo', 'milk')");
    raw.userVersion = 1;

    final db = AppDatabase(NativeDatabase.opened(raw));
    final profiles = await db.select(db.profiles).get();
    final scans = await db.select(db.scans).get();

    expect(profiles.single.name, 'Yo');
    expect(scans, isEmpty);
    expect(raw.userVersion, 2);
    await db.close();
  });

  group('pantalla de historial', () {
    testWidgets('agrupa por Hoy y Ayer y filtra por resultado', (tester) async {
      final history = InMemoryHistoryRepository([
        report(at: DateTime(2026, 10, 13, 18, 20), name: 'Galletas de mantequilla').copyWith(id: 1),
        report(at: DateTime(2026, 10, 13, 13, 5), verdict: ScanVerdict.notDetected, name: 'Chocolate de arroz').copyWith(id: 2),
        report(at: DateTime(2026, 10, 12, 20, 12), name: 'Pasta fresca').copyWith(id: 3),
      ]);
      await pumpApp(tester, history: history);
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();

      expect(find.text('HOY'), findsOneWidget);
      expect(find.text('AYER'), findsOneWidget);
      expect(find.text('18:20 · francés'), findsOneWidget);

      await tester.ensureVisible(find.text('No detectado').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('No detectado').first);
      await tester.pumpAndSettle();

      expect(find.text('Chocolate de arroz'), findsOneWidget);
      expect(find.text('Pasta fresca'), findsNothing);
    });

    testWidgets('el plan gratis borra el historial de más de 30 días', (tester) async {
      final history = InMemoryHistoryRepository([
        report(at: DateTime(2026, 8, 1), name: 'Viejo').copyWith(id: 1),
        report(at: DateTime(2026, 10, 13, 9), name: 'Nuevo').copyWith(id: 2),
      ]);
      await pumpApp(tester, history: history);
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo'), findsOneWidget);
      expect(find.text('Viejo'), findsNothing);
    });

    testWidgets('en Pro el historial se conserva siempre', (tester) async {
      final history = InMemoryHistoryRepository([report(at: DateTime(2026, 1, 1), name: 'Viejo').copyWith(id: 1)]);
      await pumpApp(tester, history: history, pro: true);
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();

      expect(find.text('Viejo'), findsOneWidget);
    });
  });
}
