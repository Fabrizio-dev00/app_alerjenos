class Profile {
  const Profile({required this.id, required this.name, required this.allergenIds});

  final int id;
  final String name;
  final Set<String> allergenIds;

  Profile copyWith({String? name, Set<String>? allergenIds}) =>
      Profile(id: id, name: name ?? this.name, allergenIds: allergenIds ?? this.allergenIds);

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.name == name &&
      other.allergenIds.length == allergenIds.length &&
      other.allergenIds.containsAll(allergenIds);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAllUnordered(allergenIds));
}

abstract interface class ProfileRepository {
  Stream<List<Profile>> watchAll();

  Future<Profile> create({required String name, required Set<String> allergenIds});

  Future<void> update(Profile profile);

  Future<void> delete(int id);
}

abstract final class ProfileLimits {
  static const free = 1;
  static const pro = 6;
  static const maxNameLength = 40;
}
