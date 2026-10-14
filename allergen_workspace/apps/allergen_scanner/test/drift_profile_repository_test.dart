import 'package:allergen_scanner/core/database/app_database.dart';
import 'package:allergen_scanner/features/profiles/data/drift_profile_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftProfileRepository repository;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftProfileRepository(db);
  });

  tearDown(() => db.close());

  test('crea perfiles con sus alérgenos y los devuelve en orden', () async {
    final me = await repository.create(name: '  Yo ', allergenIds: {'milk', 'gluten'});
    await repository.create(name: 'Sofía', allergenIds: {'peanuts', 'tree_nuts'});

    final profiles = await repository.watchAll().first;

    expect(me.name, 'Yo');
    expect(profiles.map((p) => p.name), ['Yo', 'Sofía']);
    expect(profiles.first.allergenIds, {'milk', 'gluten'});
  });

  test('un perfil sin alérgenos se guarda como conjunto vacío', () async {
    await repository.create(name: 'Invitado', allergenIds: {});

    expect((await repository.watchAll().first).single.allergenIds, isEmpty);
  });

  test('actualizar cambia nombre y alérgenos', () async {
    final me = await repository.create(name: 'Yo', allergenIds: {'milk'});

    await repository.update(me.copyWith(name: 'Fabrizio', allergenIds: {'soy', 'crustaceans', 'molluscs'}));

    final updated = (await repository.watchAll().first).single;
    expect(updated.name, 'Fabrizio');
    expect(updated.allergenIds, {'soy', 'crustaceans', 'molluscs'});
  });

  test('eliminar quita el perfil y el stream emite el cambio', () async {
    final me = await repository.create(name: 'Yo', allergenIds: {'milk'});
    final child = await repository.create(name: 'Hijo', allergenIds: {'eggs'});
    final emissions = repository.watchAll().map((list) => list.map((p) => p.name).toList());
    final expectation = expectLater(emissions, emitsThrough(['Yo']));

    await repository.delete(child.id);

    await expectation;
    expect((await repository.watchAll().first).single.id, me.id);
  });
}
