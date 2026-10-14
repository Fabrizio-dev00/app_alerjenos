// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SanoScan';

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
  String get paywallTitle => 'SanoScan Pro';

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

  @override
  String get ocrTitle => 'Detected text';

  @override
  String get ocrReading => 'Reading the label…';

  @override
  String get ocrNoText =>
      'We could not find any text. Try with more light and the ingredient list in focus.';

  @override
  String get ocrFailed => 'We could not read the image. Please try again.';

  @override
  String ocrBlocksFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count text blocks detected',
      one: '1 text block detected',
    );
    return '$_temp0';
  }

  @override
  String get ocrTapHint => 'Tap a box to see the text we read there.';

  @override
  String get ocrShowAllText => 'Show all text';

  @override
  String get ocrImageUnavailable => 'The image could not be displayed.';

  @override
  String get settingsScanLanguages => 'Scan languages';

  @override
  String get settingsScanLanguagesSubtitle =>
      'Download your languages before you travel';

  @override
  String get languagesIntro =>
      'To translate labels offline, download the label\'s language and yours. Each language takes about 30 MB and is downloaded only once.';

  @override
  String get languageDownloaded => 'Downloaded';

  @override
  String get languageNotDownloaded => 'Not downloaded';

  @override
  String get languageDownloading => 'Downloading…';

  @override
  String get languageDownload => 'Download';

  @override
  String get languageDelete => 'Delete';

  @override
  String languageDownloadFailed(String language) {
    return 'We could not download $language. Check your connection and try again.';
  }

  @override
  String get languagesLoadFailed =>
      'We could not check the downloaded languages.';

  @override
  String detectedLanguage(String language) {
    return 'Detected language: $language';
  }

  @override
  String translatedFrom(String from, String to) {
    return 'Translated from $from to $to';
  }

  @override
  String get showOriginal => 'Original';

  @override
  String get showTranslation => 'Translation';

  @override
  String translationModelMissing(String language) {
    return 'The label is in $language. To translate it offline, download the missing languages (about 30 MB each).';
  }

  @override
  String get translationDownload => 'Download and translate';

  @override
  String translationUnsupported(String code) {
    return 'The label\'s language ($code) is not supported yet. Showing the original text.';
  }

  @override
  String get translationFailed =>
      'We could not translate. Showing the original text.';

  @override
  String get languageUndetermined =>
      'We could not identify the language of the text.';

  @override
  String get ingredientsFound => 'Ingredient list found';

  @override
  String get ingredientsNotFound =>
      'We could not find the word \"Ingredients\". Move closer to the list or crop just that part to read it better.';

  @override
  String get tagline => 'Read the label. Care for what you eat.';

  @override
  String get onboardingIntro =>
      'Photograph the ingredients in any language and SanoScan looks for your allergens instantly.';

  @override
  String get statLanguages => 'languages';

  @override
  String get statAccounts => 'accounts';

  @override
  String get statOnDevice => 'on your phone';

  @override
  String get onboardingNoSignup => 'No sign-up, no ads';

  @override
  String get onboardingStart => 'Get started';

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get allergensQuestion => 'Which allergens do you avoid?';

  @override
  String get allergensSearch => 'Search allergen';

  @override
  String allergensSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected.',
      one: '1 selected.',
      zero: 'None selected.',
    );
    return '$_temp0';
  }

  @override
  String get profileStoredLocally =>
      'Your profile is stored only on this phone.';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get onboardingReadyTitle => 'Before you start';

  @override
  String get onboardingReadyBody =>
      'SanoScan helps you check labels, but text recognition can fail.';

  @override
  String get onboardingReadyRule =>
      '\"Not detected\" does not mean safe. Always check the physical label.';

  @override
  String get onboardingLanguagesHint =>
      'Travelling? Download the label languages in Settings to translate without internet.';

  @override
  String get onboardingAccept => 'Got it, let\'s start';

  @override
  String get defaultProfileName => 'Me';

  @override
  String get allergenMilk => 'Milk';

  @override
  String get allergenEggs => 'Egg';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenTreeNuts => 'Tree nuts';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenMustard => 'Mustard';

  @override
  String get allergenCelery => 'Celery';

  @override
  String get allergenSulphites => 'Sulphites';

  @override
  String get allergenLactose => 'Lactose';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergensNone => 'No allergens selected';

  @override
  String get activeProfile => 'Active profile';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get addProfile => 'Add profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get newProfile => 'New profile';

  @override
  String get profileName => 'Profile name';

  @override
  String get profileNameRequired => 'Enter a name';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String deleteProfileConfirm(String name) {
    return 'Delete the profile $name? This cannot be undone.';
  }

  @override
  String get profileActiveBadge => 'Active';

  @override
  String get useProfile => 'Use this profile';

  @override
  String scanProfile(String name) {
    return 'Profile: $name';
  }

  @override
  String get proBannerTitle => 'SanoScan Pro';

  @override
  String get proBannerSubtitle => 'Unlimited scans · USD 3.99 once';

  @override
  String get profilesProHint =>
      'With Pro you can have up to 6 profiles for the whole family.';

  @override
  String settingsOfflineReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ready',
      one: '1 ready',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String allergenPossible(String name) {
    return '$name (possible)';
  }

  @override
  String allergenTraces(String name) {
    return '$name (traces)';
  }

  @override
  String get possibleHint =>
      'The ingredient does not state its source. Check the label.';

  @override
  String get cameraGrant => 'Allow camera';

  @override
  String get cameraNeededTitle => 'We need your camera';

  @override
  String get cameraNeededBody =>
      'SanoScan only uses it to read labels. The photo never leaves your phone.';

  @override
  String get checkedTitle => 'What we checked';

  @override
  String checkedIngredients(int count, String language) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We read $count ingredients in $language',
      one: 'We read 1 ingredient in $language',
    );
    return '$_temp0';
  }

  @override
  String get checkedBothTexts =>
      'We compared the original and the translated text';

  @override
  String get checkedOriginal => 'We checked the original text';

  @override
  String get checkedQuality => 'Reading quality: good';

  @override
  String get confirmTitle => 'Is this right?';

  @override
  String confirmUnderstood(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'I understood $count allergens. If one is missing or extra, tap to fix it.',
      one:
          'I understood 1 allergen. If one is missing or extra, tap to fix it.',
    );
    return '$_temp0';
  }

  @override
  String get confirmYouSaid => 'What you said';

  @override
  String get confirmAddAnother => 'Add another allergen';

  @override
  String get confirmReviewNote =>
      'Review the list. SanoScan will only look for these allergens on labels.';

  @override
  String get confirmSave => 'Yes, save my profile';

  @override
  String get confirmSpeakAgain => 'Speak again';

  @override
  String get confirmFixManually => 'Fix by hand';

  @override
  String get editMyAllergens => 'Edit my allergens';

  @override
  String get filterAll => 'All';

  @override
  String get filterTraces => 'Traces';

  @override
  String get historyEmptyTitle => 'No scans yet';

  @override
  String get historyEmptyBody =>
      'When you scan a label it will show up here. It is only stored on your phone.';

  @override
  String get historyFilterEmpty => 'No scans with this result.';

  @override
  String get scanFirstLabel => 'Scan my first label';

  @override
  String get langEs => 'Spanish';

  @override
  String get langEn => 'English';

  @override
  String get langFr => 'French';

  @override
  String get langDe => 'German';

  @override
  String get langIt => 'Italian';

  @override
  String get langPt => 'Portuguese';

  @override
  String get langJa => 'Japanese';

  @override
  String get langKo => 'Korean';

  @override
  String get langZh => 'Chinese';

  @override
  String get langNl => 'Dutch';

  @override
  String get langUnknown => 'unknown language';

  @override
  String limitTitle(int count) {
    return 'You reached $count scans today';
  }

  @override
  String get limitBody => 'Come back tomorrow or go Pro for unlimited scans.';

  @override
  String get seePro => 'See SanoScan Pro';

  @override
  String get seeHistory => 'See history';

  @override
  String listAnd(String first, String last) {
    return '$first and $last';
  }

  @override
  String get noAllergensTitle => 'Choose your allergens';

  @override
  String get noAllergensBody =>
      'Your profile has no allergens. Choose at least one to start scanning.';

  @override
  String originalIn(String language) {
    return 'Original ($language)';
  }

  @override
  String translatedIn(String language) {
    return 'Translated ($language)';
  }

  @override
  String get readText => 'Text read';

  @override
  String readIn(String language) {
    return 'Read in $language';
  }

  @override
  String readInTranslated(String source, String target) {
    return 'Read in $source, translated to $target';
  }

  @override
  String get photoStaysOnPhone => 'Your photo never leaves the phone';

  @override
  String get privacyNoAccount =>
      'No account or sign-up needed. SanoScan does not know who you are.';

  @override
  String get privacyOnDevice =>
      'Your profiles, allergens and history are stored only on this phone.';

  @override
  String get privacyVoice =>
      'Voice is recognized on the phone and never sent to a server.';

  @override
  String get privacyPhotos =>
      'Photos are read on the phone. They are only kept if you save the scan to your history.';

  @override
  String get privacyMetrics =>
      'Only anonymous errors and metrics are recorded to improve the app, never your photos or allergens.';

  @override
  String get proTagline => 'Scan without limits, look after your whole family.';

  @override
  String get proFree => 'Free';

  @override
  String get proRowScans => 'Scans per day';

  @override
  String get proRowLanguages => '6 offline languages';

  @override
  String get proUnlimited => 'Unlimited';

  @override
  String get proUpToSix => 'Up to 6';

  @override
  String get proThirtyDays => '30 days';

  @override
  String get proForever => 'Forever';

  @override
  String get yes => 'Yes';

  @override
  String get proOneTime => 'one-time payment. No subscription.';

  @override
  String proUnlock(String price) {
    return 'Unlock Pro for $price';
  }

  @override
  String get proRestore => 'Restore purchase';

  @override
  String get proNotNow => 'Not now';

  @override
  String get proStoreNote =>
      'Payment happens in your phone store. No account needed.';

  @override
  String get purchaseNotReady => 'Purchases will be enabled before launch.';

  @override
  String get proActive => 'Active';

  @override
  String get proActiveBody =>
      'One-time purchase. Unlimited scans and profiles.';

  @override
  String profileDefaultName(int number) {
    return 'Profile $number';
  }

  @override
  String profilesCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String profilesIntro(int count, int max) {
    return '$count of $max profiles. Each person has their own allergens.';
  }

  @override
  String get profilesNote =>
      'The active profile is the one the scanner uses. Each profile allergens are stored only on this phone.';

  @override
  String quotaRemaining(int remaining, int total) {
    return '$remaining of $total scans left today ·';
  }

  @override
  String resultContainsSubtitle(int count, String profile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count allergens from your profile $profile',
      one: '1 allergen from your profile $profile',
    );
    return '$_temp0';
  }

  @override
  String resultTracesSubtitle(int count, String profile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The maker warns of possible cross-contamination with $count allergens from your profile $profile.',
      one:
          'The maker warns of possible cross-contamination with 1 allergen from your profile $profile.',
    );
    return '$_temp0';
  }

  @override
  String resultNotDetectedSubtitle(String profile) {
    return 'We found no allergens from your profile $profile in the text we read.';
  }

  @override
  String get sanoName => 'Sano';

  @override
  String get save => 'Save';

  @override
  String get saveScanTitle => 'Save to history';

  @override
  String get saveScanHint => 'Product name (optional)';

  @override
  String get savedToHistory => 'Saved to history';

  @override
  String get scanAnother => 'Scan another';

  @override
  String get scannerHint => 'Bring the label closer and tap';

  @override
  String get settingsOfflineLanguages => 'Offline languages';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyValue => 'Only on your phone';

  @override
  String get settingsSaveHistory => 'Save history';

  @override
  String get settingsVibrate => 'Vibrate on scan';

  @override
  String get stepReading => 'Reading the text…';

  @override
  String get stepRead => 'Text read';

  @override
  String stepReadLanguage(String language) {
    return 'Text read · $language detected';
  }

  @override
  String stepTranslating(String language) {
    return 'Translating to $language…';
  }

  @override
  String stepTranslated(String language) {
    return 'Translated to $language';
  }

  @override
  String stepAlreadyIn(String language) {
    return 'Already in $language';
  }

  @override
  String stepModelMissing(String language) {
    return 'No translation: $language is not downloaded';
  }

  @override
  String get stepOriginalOnly => 'Checking the original text';

  @override
  String get stepMatching => 'Looking for your allergens…';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unnamedScan => 'Unnamed scan';

  @override
  String get unreadableTitle => 'We could not read the label';

  @override
  String get unreadableBody =>
      'Bring the label closer, improve the light and avoid glare.';

  @override
  String get voiceChooseManually => 'Choose by hand';

  @override
  String get voicePrompt =>
      'Hi, I am Sano. Tell me which allergens you react to. You can speak or type.';

  @override
  String get voiceListening => 'Listening… tap the microphone when you finish';

  @override
  String get voiceTapToSpeak => 'Tap the microphone and speak';

  @override
  String get voicePrivacy =>
      'Your voice is processed on your phone and never sent to a server.';

  @override
  String get voiceTypeHint => 'Or type here…';

  @override
  String get voiceMicLabel => 'Microphone';

  @override
  String get voiceDenied =>
      'No microphone permission. You can type or choose by hand.';

  @override
  String get voiceNoMatch =>
      'I did not catch that. Tap the microphone and try again.';

  @override
  String get voiceOfflineUnsupported =>
      'Your phone has no offline speech recognition for this language. Type or choose by hand.';

  @override
  String get voiceUnavailable =>
      'Speech recognition is not available. Type or choose by hand.';

  @override
  String get voiceNothingFound =>
      'I did not recognize any allergen. Try again or choose by hand.';

  @override
  String get saved => 'Saved';
}
