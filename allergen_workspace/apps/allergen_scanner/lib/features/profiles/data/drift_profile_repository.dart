import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/profile.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._db);

  final AppDatabase _db;

  static Set<String> _decode(String value) =>
      value.isEmpty ? <String>{} : value.split(',').where((id) => id.isNotEmpty).toSet();

  static String _encode(Set<String> ids) => (ids.toList()..sort()).join(',');

  static Profile _toProfile(ProfileRow row) =>
      Profile(id: row.id, name: row.name, allergenIds: _decode(row.allergens));

  @override
  Stream<List<Profile>> watchAll() {
    final query = _db.select(_db.profiles)..orderBy([(p) => OrderingTerm.asc(p.id)]);
    return query.watch().map((rows) => rows.map(_toProfile).toList());
  }

  @override
  Future<Profile> create({required String name, required Set<String> allergenIds}) async {
    final row = await _db.into(_db.profiles).insertReturning(
          ProfilesCompanion.insert(name: name.trim(), allergens: Value(_encode(allergenIds))),
        );
    return _toProfile(row);
  }

  @override
  Future<void> update(Profile profile) async {
    await (_db.update(_db.profiles)..where((p) => p.id.equals(profile.id))).write(
      ProfilesCompanion(name: Value(profile.name.trim()), allergens: Value(_encode(profile.allergenIds))),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.profiles)..where((p) => p.id.equals(id))).go();
  }
}
