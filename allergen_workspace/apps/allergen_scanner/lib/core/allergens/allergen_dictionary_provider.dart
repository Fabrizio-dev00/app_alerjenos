import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'allergen_dictionary.dart';

const allergenDictionaryAsset = 'assets/allergens.json';

final allergenDictionaryProvider = FutureProvider<AllergenDictionary>((ref) async {
  final source = await rootBundle.loadString(allergenDictionaryAsset, cache: false);
  return AllergenDictionary.parse(source);
});
