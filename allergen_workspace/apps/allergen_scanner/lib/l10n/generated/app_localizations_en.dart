// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Allergen Scanner';

  @override
  String get navScan => 'Scan';

  @override
  String get navHistory => 'History';

  @override
  String get navProfiles => 'Profiles';

  @override
  String get navSettings => 'Settings';

  @override
  String get scanHeadline => 'Check a label';

  @override
  String get scanDescription =>
      'Take a photo of the ingredient list and we will help you check it against your profile.';

  @override
  String get scanTakePhoto => 'Take photo';

  @override
  String get scanFromGallery => 'Choose from gallery';

  @override
  String get safetyNotice =>
      '\"Not detected\" does not mean safe. Text recognition can fail: the physical label always comes first.';

  @override
  String get historyEmpty => 'No scans yet.';

  @override
  String get profilesEmpty => 'Create your profile to choose your allergens.';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsLanguageSystem => 'Use system language';

  @override
  String get paywallTitle => 'Scanner Pro';

  @override
  String get paywallDescription =>
      'Unlimited scans and profiles for the whole family with a single payment.';

  @override
  String get resultContains => 'Contains';

  @override
  String get resultMayContain => 'May contain traces';

  @override
  String get resultNotDetected => 'Not detected';
}
