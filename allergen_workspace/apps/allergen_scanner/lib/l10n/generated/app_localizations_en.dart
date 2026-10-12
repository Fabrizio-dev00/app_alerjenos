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

  @override
  String get cameraDenied =>
      'We need the camera to read the label. You can also choose a photo from your gallery.';

  @override
  String get cameraBlocked =>
      'Camera permission is blocked. Turn it on in your phone settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get retry => 'Try again';

  @override
  String get galleryFailed =>
      'We could not open the gallery. Please try again.';

  @override
  String get cropFailed => 'We could not crop the image. Please try again.';

  @override
  String get cropTitle => 'Crop the ingredients';

  @override
  String get cameraUnavailable => 'No camera is available on this device.';

  @override
  String get cameraFailed => 'We could not use the camera. Please try again.';

  @override
  String get cameraHint => 'Frame the ingredient list in good light';

  @override
  String get torchOn => 'Turn on flashlight';

  @override
  String get torchOff => 'Turn off flashlight';

  @override
  String get previewTitle => 'Check the photo';

  @override
  String get previewHint =>
      'Make sure the whole ingredient list is sharp and readable.';

  @override
  String get previewAnalyze => 'Analyze label';

  @override
  String get previewRetake => 'Use another photo';

  @override
  String get previewImageMissing =>
      'We could not find the image. Please take the photo again.';
}
