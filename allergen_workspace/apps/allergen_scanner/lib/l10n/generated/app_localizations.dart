import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'SanoScan'**
  String get appTitle;

  /// No description provided for @navScan.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get navScan;

  /// No description provided for @navHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistory;

  /// No description provided for @navProfiles.
  ///
  /// In es, this message translates to:
  /// **'Perfiles'**
  String get navProfiles;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @scanHeadline.
  ///
  /// In es, this message translates to:
  /// **'Revisa una etiqueta'**
  String get scanHeadline;

  /// No description provided for @scanDescription.
  ///
  /// In es, this message translates to:
  /// **'Toma una foto de la lista de ingredientes y te ayudamos a revisar si tiene algo de tu perfil.'**
  String get scanDescription;

  /// No description provided for @scanTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get scanTakePhoto;

  /// No description provided for @scanFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get scanFromGallery;

  /// No description provided for @safetyNotice.
  ///
  /// In es, this message translates to:
  /// **'\"No detectado\" no significa seguro. El reconocimiento de texto puede fallar: la etiqueta física siempre manda.'**
  String get safetyNotice;

  /// No description provided for @historyEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes escaneos.'**
  String get historyEmpty;

  /// No description provided for @profilesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Crea tu perfil para elegir tus alérgenos.'**
  String get profilesEmpty;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In es, this message translates to:
  /// **'Usar el del sistema'**
  String get settingsLanguageSystem;

  /// No description provided for @paywallTitle.
  ///
  /// In es, this message translates to:
  /// **'SanoScan Pro'**
  String get paywallTitle;

  /// No description provided for @paywallDescription.
  ///
  /// In es, this message translates to:
  /// **'Escaneos ilimitados y perfiles para toda la familia con un solo pago.'**
  String get paywallDescription;

  /// No description provided for @resultContains.
  ///
  /// In es, this message translates to:
  /// **'Contiene'**
  String get resultContains;

  /// No description provided for @resultMayContain.
  ///
  /// In es, this message translates to:
  /// **'Puede contener trazas'**
  String get resultMayContain;

  /// No description provided for @resultNotDetected.
  ///
  /// In es, this message translates to:
  /// **'No detectado'**
  String get resultNotDetected;

  /// No description provided for @cameraDenied.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos la cámara para leer la etiqueta. También puedes elegir una foto de la galería.'**
  String get cameraDenied;

  /// No description provided for @cameraBlocked.
  ///
  /// In es, this message translates to:
  /// **'El permiso de cámara está bloqueado. Actívalo en los ajustes del teléfono.'**
  String get cameraBlocked;

  /// No description provided for @openSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get openSettings;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @galleryFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la galería. Inténtalo de nuevo.'**
  String get galleryFailed;

  /// No description provided for @cropFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos recortar la imagen. Inténtalo de nuevo.'**
  String get cropFailed;

  /// No description provided for @cropTitle.
  ///
  /// In es, this message translates to:
  /// **'Recorta los ingredientes'**
  String get cropTitle;

  /// No description provided for @cameraUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No encontramos una cámara disponible en este dispositivo.'**
  String get cameraUnavailable;

  /// No description provided for @cameraFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos usar la cámara. Inténtalo de nuevo.'**
  String get cameraFailed;

  /// No description provided for @cameraHint.
  ///
  /// In es, this message translates to:
  /// **'Encuadra la lista de ingredientes con buena luz'**
  String get cameraHint;

  /// No description provided for @torchOn.
  ///
  /// In es, this message translates to:
  /// **'Encender linterna'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In es, this message translates to:
  /// **'Apagar linterna'**
  String get torchOff;

  /// No description provided for @previewTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa la foto'**
  String get previewTitle;

  /// No description provided for @previewHint.
  ///
  /// In es, this message translates to:
  /// **'Comprueba que la lista de ingredientes se lea completa y nítida.'**
  String get previewHint;

  /// No description provided for @previewAnalyze.
  ///
  /// In es, this message translates to:
  /// **'Analizar etiqueta'**
  String get previewAnalyze;

  /// No description provided for @previewRetake.
  ///
  /// In es, this message translates to:
  /// **'Usar otra foto'**
  String get previewRetake;

  /// No description provided for @previewImageMissing.
  ///
  /// In es, this message translates to:
  /// **'No encontramos la imagen. Vuelve a tomar la foto.'**
  String get previewImageMissing;

  /// No description provided for @ocrTitle.
  ///
  /// In es, this message translates to:
  /// **'Texto detectado'**
  String get ocrTitle;

  /// No description provided for @ocrReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo la etiqueta…'**
  String get ocrReading;

  /// No description provided for @ocrNoText.
  ///
  /// In es, this message translates to:
  /// **'No encontramos texto. Prueba con más luz y con la lista de ingredientes bien enfocada.'**
  String get ocrNoText;

  /// No description provided for @ocrFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer la imagen. Inténtalo de nuevo.'**
  String get ocrFailed;

  /// No description provided for @ocrBlocksFound.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 bloque de texto detectado} other{{count} bloques de texto detectados}}'**
  String ocrBlocksFound(int count);

  /// No description provided for @ocrTapHint.
  ///
  /// In es, this message translates to:
  /// **'Toca un recuadro para ver el texto que leímos ahí.'**
  String get ocrTapHint;

  /// No description provided for @ocrShowAllText.
  ///
  /// In es, this message translates to:
  /// **'Ver todo el texto'**
  String get ocrShowAllText;

  /// No description provided for @ocrImageUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo mostrar la imagen.'**
  String get ocrImageUnavailable;

  /// No description provided for @settingsScanLanguages.
  ///
  /// In es, this message translates to:
  /// **'Idiomas para escanear'**
  String get settingsScanLanguages;

  /// No description provided for @settingsScanLanguagesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descarga tus idiomas antes de viajar'**
  String get settingsScanLanguagesSubtitle;

  /// No description provided for @languagesIntro.
  ///
  /// In es, this message translates to:
  /// **'Para traducir etiquetas sin internet, descarga el idioma de la etiqueta y el tuyo. Cada idioma ocupa unos 30 MB y se descarga una sola vez.'**
  String get languagesIntro;

  /// No description provided for @languageDownloaded.
  ///
  /// In es, this message translates to:
  /// **'Descargado'**
  String get languageDownloaded;

  /// No description provided for @languageNotDownloaded.
  ///
  /// In es, this message translates to:
  /// **'No descargado'**
  String get languageNotDownloaded;

  /// No description provided for @languageDownloading.
  ///
  /// In es, this message translates to:
  /// **'Descargando…'**
  String get languageDownloading;

  /// No description provided for @languageDownload.
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get languageDownload;

  /// No description provided for @languageDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get languageDelete;

  /// No description provided for @languageDownloadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos descargar {language}. Revisa tu conexión e inténtalo de nuevo.'**
  String languageDownloadFailed(String language);

  /// No description provided for @languagesLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos revisar los idiomas descargados.'**
  String get languagesLoadFailed;

  /// No description provided for @detectedLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma detectado: {language}'**
  String detectedLanguage(String language);

  /// No description provided for @translatedFrom.
  ///
  /// In es, this message translates to:
  /// **'Traducido de {from} a {to}'**
  String translatedFrom(String from, String to);

  /// No description provided for @showOriginal.
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get showOriginal;

  /// No description provided for @showTranslation.
  ///
  /// In es, this message translates to:
  /// **'Traducción'**
  String get showTranslation;

  /// No description provided for @translationModelMissing.
  ///
  /// In es, this message translates to:
  /// **'La etiqueta está en {language}. Para traducirla sin internet descarga los idiomas que faltan (unos 30 MB cada uno).'**
  String translationModelMissing(String language);

  /// No description provided for @translationDownload.
  ///
  /// In es, this message translates to:
  /// **'Descargar y traducir'**
  String get translationDownload;

  /// No description provided for @translationUnsupported.
  ///
  /// In es, this message translates to:
  /// **'El idioma de la etiqueta ({code}) todavía no está soportado. Se muestra el texto original.'**
  String translationUnsupported(String code);

  /// No description provided for @translationFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos traducir. Se muestra el texto original.'**
  String get translationFailed;

  /// No description provided for @languageUndetermined.
  ///
  /// In es, this message translates to:
  /// **'No pudimos identificar el idioma del texto.'**
  String get languageUndetermined;

  /// No description provided for @ingredientsFound.
  ///
  /// In es, this message translates to:
  /// **'Lista de ingredientes encontrada'**
  String get ingredientsFound;

  /// No description provided for @ingredientsNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos la palabra «Ingredientes». Acerca la cámara a la lista o recorta solo esa parte para leerla mejor.'**
  String get ingredientsNotFound;

  /// No description provided for @tagline.
  ///
  /// In es, this message translates to:
  /// **'Lee la etiqueta. Cuida lo que comes.'**
  String get tagline;

  /// No description provided for @onboardingIntro.
  ///
  /// In es, this message translates to:
  /// **'Fotografía los ingredientes en cualquier idioma y SanoScan busca tus alérgenos al instante.'**
  String get onboardingIntro;

  /// No description provided for @statLanguages.
  ///
  /// In es, this message translates to:
  /// **'idiomas'**
  String get statLanguages;

  /// No description provided for @statAccounts.
  ///
  /// In es, this message translates to:
  /// **'cuentas'**
  String get statAccounts;

  /// No description provided for @statOnDevice.
  ///
  /// In es, this message translates to:
  /// **'en tu móvil'**
  String get statOnDevice;

  /// No description provided for @onboardingNoSignup.
  ///
  /// In es, this message translates to:
  /// **'Sin registro, sin anuncios'**
  String get onboardingNoSignup;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingStart;

  /// No description provided for @onboardingStep.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @allergensQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué alérgenos evitas?'**
  String get allergensQuestion;

  /// No description provided for @allergensSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar alérgeno'**
  String get allergensSearch;

  /// No description provided for @allergensSelected.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Ninguno elegido.} =1{1 elegido.} other{{count} elegidos.}}'**
  String allergensSelected(int count);

  /// No description provided for @profileStoredLocally.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil se guarda solo en este móvil.'**
  String get profileStoredLocally;

  /// No description provided for @saveProfile.
  ///
  /// In es, this message translates to:
  /// **'Guardar perfil'**
  String get saveProfile;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'Antes de empezar'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadyBody.
  ///
  /// In es, this message translates to:
  /// **'SanoScan te ayuda a revisar etiquetas, pero el reconocimiento de texto puede fallar.'**
  String get onboardingReadyBody;

  /// No description provided for @onboardingReadyRule.
  ///
  /// In es, this message translates to:
  /// **'«No detectado» no significa seguro. Revisa siempre la etiqueta física.'**
  String get onboardingReadyRule;

  /// No description provided for @onboardingLanguagesHint.
  ///
  /// In es, this message translates to:
  /// **'¿Vas a viajar? Descarga los idiomas de las etiquetas en Ajustes para traducir sin internet.'**
  String get onboardingLanguagesHint;

  /// No description provided for @onboardingAccept.
  ///
  /// In es, this message translates to:
  /// **'Entendido, empezar'**
  String get onboardingAccept;

  /// No description provided for @defaultProfileName.
  ///
  /// In es, this message translates to:
  /// **'Yo'**
  String get defaultProfileName;

  /// No description provided for @allergenMilk.
  ///
  /// In es, this message translates to:
  /// **'Leche'**
  String get allergenMilk;

  /// No description provided for @allergenEggs.
  ///
  /// In es, this message translates to:
  /// **'Huevo'**
  String get allergenEggs;

  /// No description provided for @allergenGluten.
  ///
  /// In es, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenPeanuts.
  ///
  /// In es, this message translates to:
  /// **'Maní'**
  String get allergenPeanuts;

  /// No description provided for @allergenTreeNuts.
  ///
  /// In es, this message translates to:
  /// **'Frutos secos'**
  String get allergenTreeNuts;

  /// No description provided for @allergenSoy.
  ///
  /// In es, this message translates to:
  /// **'Soja'**
  String get allergenSoy;

  /// No description provided for @allergenFish.
  ///
  /// In es, this message translates to:
  /// **'Pescado'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In es, this message translates to:
  /// **'Mariscos'**
  String get allergenShellfish;

  /// No description provided for @allergenSesame.
  ///
  /// In es, this message translates to:
  /// **'Ajonjolí'**
  String get allergenSesame;

  /// No description provided for @allergenMustard.
  ///
  /// In es, this message translates to:
  /// **'Mostaza'**
  String get allergenMustard;

  /// No description provided for @allergenCelery.
  ///
  /// In es, this message translates to:
  /// **'Apio'**
  String get allergenCelery;

  /// No description provided for @allergenSulphites.
  ///
  /// In es, this message translates to:
  /// **'Sulfitos'**
  String get allergenSulphites;

  /// No description provided for @allergenLactose.
  ///
  /// In es, this message translates to:
  /// **'Lactosa'**
  String get allergenLactose;

  /// No description provided for @allergenLupin.
  ///
  /// In es, this message translates to:
  /// **'Tarwi (altramuz)'**
  String get allergenLupin;

  /// No description provided for @allergensNone.
  ///
  /// In es, this message translates to:
  /// **'Sin alérgenos elegidos'**
  String get allergensNone;

  /// No description provided for @activeProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil activo'**
  String get activeProfile;

  /// No description provided for @profilesTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfiles'**
  String get profilesTitle;

  /// No description provided for @addProfile.
  ///
  /// In es, this message translates to:
  /// **'Agregar perfil'**
  String get addProfile;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @newProfile.
  ///
  /// In es, this message translates to:
  /// **'Nuevo perfil'**
  String get newProfile;

  /// No description provided for @profileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del perfil'**
  String get profileName;

  /// No description provided for @profileNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre'**
  String get profileNameRequired;

  /// No description provided for @deleteProfile.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el perfil {name}? No se puede deshacer.'**
  String deleteProfileConfirm(String name);

  /// No description provided for @profileActiveBadge.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get profileActiveBadge;

  /// No description provided for @useProfile.
  ///
  /// In es, this message translates to:
  /// **'Usar este perfil'**
  String get useProfile;

  /// No description provided for @scanProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil: {name}'**
  String scanProfile(String name);

  /// No description provided for @proBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'SanoScan Pro'**
  String get proBannerTitle;

  /// No description provided for @proBannerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sin límite de escaneos · USD 3.99 una vez'**
  String get proBannerSubtitle;

  /// No description provided for @profilesProHint.
  ///
  /// In es, this message translates to:
  /// **'Con Pro puedes tener hasta 6 perfiles para toda la familia.'**
  String get profilesProHint;

  /// No description provided for @settingsOfflineReady.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Ninguno} =1{1 listo} other{{count} listos}}'**
  String settingsOfflineReady(int count);

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String settingsVersion(String version);

  /// No description provided for @allergenPossible.
  ///
  /// In es, this message translates to:
  /// **'{name} (posible)'**
  String allergenPossible(String name);

  /// No description provided for @allergenTraces.
  ///
  /// In es, this message translates to:
  /// **'{name} (trazas)'**
  String allergenTraces(String name);

  /// No description provided for @possibleHint.
  ///
  /// In es, this message translates to:
  /// **'El ingrediente no dice su origen. Revisa la etiqueta.'**
  String get possibleHint;

  /// No description provided for @cameraGrant.
  ///
  /// In es, this message translates to:
  /// **'Dar permiso'**
  String get cameraGrant;

  /// No description provided for @cameraNeededTitle.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos tu cámara'**
  String get cameraNeededTitle;

  /// No description provided for @cameraNeededBody.
  ///
  /// In es, this message translates to:
  /// **'SanoScan la usa solo para leer etiquetas. La foto no sale de tu teléfono.'**
  String get cameraNeededBody;

  /// No description provided for @checkedTitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que revisamos'**
  String get checkedTitle;

  /// No description provided for @checkedIngredients.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Leímos 1 ingrediente en {language}} other{Leímos {count} ingredientes en {language}}}'**
  String checkedIngredients(int count, String language);

  /// No description provided for @checkedBothTexts.
  ///
  /// In es, this message translates to:
  /// **'Comparamos el texto original y el traducido'**
  String get checkedBothTexts;

  /// No description provided for @checkedOriginal.
  ///
  /// In es, this message translates to:
  /// **'Revisamos el texto original'**
  String get checkedOriginal;

  /// No description provided for @checkedQuality.
  ///
  /// In es, this message translates to:
  /// **'Calidad de lectura: buena'**
  String get checkedQuality;

  /// No description provided for @confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Es esto correcto?'**
  String get confirmTitle;

  /// No description provided for @confirmUnderstood.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Entendí 1 alérgeno. Si falta uno o sobra otro, tócalo para corregir.} other{Entendí {count} alérgenos. Si falta uno o sobra otro, tócalo para corregir.}}'**
  String confirmUnderstood(int count);

  /// No description provided for @confirmYouSaid.
  ///
  /// In es, this message translates to:
  /// **'Lo que dijiste'**
  String get confirmYouSaid;

  /// No description provided for @confirmAddAnother.
  ///
  /// In es, this message translates to:
  /// **'Añadir otro alérgeno'**
  String get confirmAddAnother;

  /// No description provided for @confirmReviewNote.
  ///
  /// In es, this message translates to:
  /// **'Revisa la lista. SanoScan solo buscará estos alérgenos en las etiquetas.'**
  String get confirmReviewNote;

  /// No description provided for @confirmSave.
  ///
  /// In es, this message translates to:
  /// **'Sí, guardar mi perfil'**
  String get confirmSave;

  /// No description provided for @confirmSpeakAgain.
  ///
  /// In es, this message translates to:
  /// **'Hablar otra vez'**
  String get confirmSpeakAgain;

  /// No description provided for @confirmFixManually.
  ///
  /// In es, this message translates to:
  /// **'Corregir a mano'**
  String get confirmFixManually;

  /// No description provided for @editMyAllergens.
  ///
  /// In es, this message translates to:
  /// **'Editar mis alérgenos'**
  String get editMyAllergens;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterTraces.
  ///
  /// In es, this message translates to:
  /// **'Trazas'**
  String get filterTraces;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay escaneos'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando escanees una etiqueta, aparecerá aquí. Solo se guarda en tu móvil.'**
  String get historyEmptyBody;

  /// No description provided for @historyFilterEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay escaneos con este resultado.'**
  String get historyFilterEmpty;

  /// No description provided for @scanFirstLabel.
  ///
  /// In es, this message translates to:
  /// **'Escanear mi primera etiqueta'**
  String get scanFirstLabel;

  /// No description provided for @langEs.
  ///
  /// In es, this message translates to:
  /// **'español'**
  String get langEs;

  /// No description provided for @langEn.
  ///
  /// In es, this message translates to:
  /// **'inglés'**
  String get langEn;

  /// No description provided for @langFr.
  ///
  /// In es, this message translates to:
  /// **'francés'**
  String get langFr;

  /// No description provided for @langDe.
  ///
  /// In es, this message translates to:
  /// **'alemán'**
  String get langDe;

  /// No description provided for @langIt.
  ///
  /// In es, this message translates to:
  /// **'italiano'**
  String get langIt;

  /// No description provided for @langPt.
  ///
  /// In es, this message translates to:
  /// **'portugués'**
  String get langPt;

  /// No description provided for @langJa.
  ///
  /// In es, this message translates to:
  /// **'japonés'**
  String get langJa;

  /// No description provided for @langKo.
  ///
  /// In es, this message translates to:
  /// **'coreano'**
  String get langKo;

  /// No description provided for @langZh.
  ///
  /// In es, this message translates to:
  /// **'chino'**
  String get langZh;

  /// No description provided for @langNl.
  ///
  /// In es, this message translates to:
  /// **'neerlandés'**
  String get langNl;

  /// No description provided for @langUnknown.
  ///
  /// In es, this message translates to:
  /// **'idioma desconocido'**
  String get langUnknown;

  /// No description provided for @limitTitle.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a {count} escaneos hoy'**
  String limitTitle(int count);

  /// No description provided for @limitBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve mañana o pasa a Pro para escanear sin límites.'**
  String get limitBody;

  /// No description provided for @seePro.
  ///
  /// In es, this message translates to:
  /// **'Ver SanoScan Pro'**
  String get seePro;

  /// No description provided for @seeHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial'**
  String get seeHistory;

  /// No description provided for @listAnd.
  ///
  /// In es, this message translates to:
  /// **'{first} y {last}'**
  String listAnd(String first, String last);

  /// No description provided for @noAllergensTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tus alérgenos'**
  String get noAllergensTitle;

  /// No description provided for @noAllergensBody.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene alérgenos. Elige al menos uno para empezar a escanear.'**
  String get noAllergensBody;

  /// No description provided for @originalIn.
  ///
  /// In es, this message translates to:
  /// **'Original ({language})'**
  String originalIn(String language);

  /// No description provided for @translatedIn.
  ///
  /// In es, this message translates to:
  /// **'Traducido ({language})'**
  String translatedIn(String language);

  /// No description provided for @readText.
  ///
  /// In es, this message translates to:
  /// **'Texto leído'**
  String get readText;

  /// No description provided for @readIn.
  ///
  /// In es, this message translates to:
  /// **'Leído en {language}'**
  String readIn(String language);

  /// No description provided for @readInTranslated.
  ///
  /// In es, this message translates to:
  /// **'Leído en {source}, traducido al {target}'**
  String readInTranslated(String source, String target);

  /// No description provided for @photoStaysOnPhone.
  ///
  /// In es, this message translates to:
  /// **'Tu foto no sale del teléfono'**
  String get photoStaysOnPhone;

  /// No description provided for @privacyNoAccount.
  ///
  /// In es, this message translates to:
  /// **'No necesitas cuenta ni registro. SanoScan no sabe quién eres.'**
  String get privacyNoAccount;

  /// No description provided for @privacyOnDevice.
  ///
  /// In es, this message translates to:
  /// **'Tus perfiles, alérgenos e historial se guardan solo en este teléfono.'**
  String get privacyOnDevice;

  /// No description provided for @privacyVoice.
  ///
  /// In es, this message translates to:
  /// **'La voz se reconoce en el teléfono y no se envía a ningún servidor.'**
  String get privacyVoice;

  /// No description provided for @privacyPhotos.
  ///
  /// In es, this message translates to:
  /// **'Las fotos se leen en el teléfono. Solo se guardan si guardas el escaneo en el historial.'**
  String get privacyPhotos;

  /// No description provided for @privacyMetrics.
  ///
  /// In es, this message translates to:
  /// **'Si lo permites, se envían errores y métricas anónimas para mejorar la app, nunca tus fotos, alérgenos ni perfiles. Puedes desactivarlo abajo.'**
  String get privacyMetrics;

  /// No description provided for @proTagline.
  ///
  /// In es, this message translates to:
  /// **'Escanea sin límites, cuida a toda tu familia.'**
  String get proTagline;

  /// No description provided for @proFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get proFree;

  /// No description provided for @proRowScans.
  ///
  /// In es, this message translates to:
  /// **'Escaneos al día'**
  String get proRowScans;

  /// No description provided for @proRowLanguages.
  ///
  /// In es, this message translates to:
  /// **'6 idiomas sin conexión'**
  String get proRowLanguages;

  /// No description provided for @proUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Sin límite'**
  String get proUnlimited;

  /// No description provided for @proUpToSix.
  ///
  /// In es, this message translates to:
  /// **'Hasta 6'**
  String get proUpToSix;

  /// No description provided for @proThirtyDays.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get proThirtyDays;

  /// No description provided for @proForever.
  ///
  /// In es, this message translates to:
  /// **'Siempre'**
  String get proForever;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @proOneTime.
  ///
  /// In es, this message translates to:
  /// **'pago único. Sin suscripción.'**
  String get proOneTime;

  /// No description provided for @proUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Pro por {price}'**
  String proUnlock(String price);

  /// No description provided for @proRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compra'**
  String get proRestore;

  /// No description provided for @proNotNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get proNotNow;

  /// No description provided for @proStoreNote.
  ///
  /// In es, this message translates to:
  /// **'El pago se hace en la tienda de tu móvil. No necesitas crear una cuenta.'**
  String get proStoreNote;

  /// No description provided for @purchaseNotReady.
  ///
  /// In es, this message translates to:
  /// **'Las compras se activan antes del lanzamiento.'**
  String get purchaseNotReady;

  /// No description provided for @proActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get proActive;

  /// No description provided for @proActiveBody.
  ///
  /// In es, this message translates to:
  /// **'Compra única. Escaneos y perfiles sin límite.'**
  String get proActiveBody;

  /// No description provided for @profileDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Perfil {number}'**
  String profileDefaultName(int number);

  /// No description provided for @profilesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} de {max}'**
  String profilesCount(int count, int max);

  /// No description provided for @profilesIntro.
  ///
  /// In es, this message translates to:
  /// **'{count} de {max} perfiles. Cada persona tiene sus propios alérgenos.'**
  String profilesIntro(int count, int max);

  /// No description provided for @profilesNote.
  ///
  /// In es, this message translates to:
  /// **'El perfil activo es el que usa el escáner. Los alérgenos de cada perfil se guardan solo en este teléfono.'**
  String get profilesNote;

  /// No description provided for @quotaRemaining.
  ///
  /// In es, this message translates to:
  /// **'Te quedan {remaining} de {total} escaneos hoy ·'**
  String quotaRemaining(int remaining, int total);

  /// No description provided for @resultContainsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 alérgeno de tu perfil {profile}} other{{count} alérgenos de tu perfil {profile}}}'**
  String resultContainsSubtitle(int count, String profile);

  /// No description provided for @resultTracesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{El fabricante avisa de posible contaminación cruzada con 1 alérgeno de tu perfil {profile}.} other{El fabricante avisa de posible contaminación cruzada con {count} alérgenos de tu perfil {profile}.}}'**
  String resultTracesSubtitle(int count, String profile);

  /// No description provided for @resultNotDetectedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos alérgenos de tu perfil {profile} en el texto que leímos.'**
  String resultNotDetectedSubtitle(String profile);

  /// No description provided for @sanoName.
  ///
  /// In es, this message translates to:
  /// **'Sano'**
  String get sanoName;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @saveScanTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar en el historial'**
  String get saveScanTitle;

  /// No description provided for @saveScanHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto (opcional)'**
  String get saveScanHint;

  /// No description provided for @savedToHistory.
  ///
  /// In es, this message translates to:
  /// **'Guardado en el historial'**
  String get savedToHistory;

  /// No description provided for @scanAnother.
  ///
  /// In es, this message translates to:
  /// **'Escanear otra'**
  String get scanAnother;

  /// No description provided for @scannerHint.
  ///
  /// In es, this message translates to:
  /// **'Acerca la etiqueta y toca'**
  String get scannerHint;

  /// No description provided for @settingsOfflineLanguages.
  ///
  /// In es, this message translates to:
  /// **'Idiomas sin conexión'**
  String get settingsOfflineLanguages;

  /// No description provided for @settingsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyValue.
  ///
  /// In es, this message translates to:
  /// **'Solo en tu móvil'**
  String get settingsPrivacyValue;

  /// No description provided for @settingsSaveHistory.
  ///
  /// In es, this message translates to:
  /// **'Guardar historial'**
  String get settingsSaveHistory;

  /// No description provided for @settingsVibrate.
  ///
  /// In es, this message translates to:
  /// **'Vibración al escanear'**
  String get settingsVibrate;

  /// No description provided for @stepReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo el texto…'**
  String get stepReading;

  /// No description provided for @stepRead.
  ///
  /// In es, this message translates to:
  /// **'Texto leído'**
  String get stepRead;

  /// No description provided for @stepReadLanguage.
  ///
  /// In es, this message translates to:
  /// **'Texto leído · {language} detectado'**
  String stepReadLanguage(String language);

  /// No description provided for @stepTranslating.
  ///
  /// In es, this message translates to:
  /// **'Traduciendo al {language}…'**
  String stepTranslating(String language);

  /// No description provided for @stepTranslated.
  ///
  /// In es, this message translates to:
  /// **'Traducido al {language}'**
  String stepTranslated(String language);

  /// No description provided for @stepAlreadyIn.
  ///
  /// In es, this message translates to:
  /// **'Ya está en {language}'**
  String stepAlreadyIn(String language);

  /// No description provided for @stepModelMissing.
  ///
  /// In es, this message translates to:
  /// **'Sin traducción: falta descargar {language}'**
  String stepModelMissing(String language);

  /// No description provided for @stepOriginalOnly.
  ///
  /// In es, this message translates to:
  /// **'Se revisa el texto original'**
  String get stepOriginalOnly;

  /// No description provided for @stepMatching.
  ///
  /// In es, this message translates to:
  /// **'Buscando tus alérgenos…'**
  String get stepMatching;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get tryAgain;

  /// No description provided for @unnamedScan.
  ///
  /// In es, this message translates to:
  /// **'Escaneo sin nombre'**
  String get unnamedScan;

  /// No description provided for @unreadableTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer la etiqueta'**
  String get unreadableTitle;

  /// No description provided for @unreadableBody.
  ///
  /// In es, this message translates to:
  /// **'Acerca la etiqueta, mejora la luz y evita los reflejos.'**
  String get unreadableBody;

  /// No description provided for @voiceChooseManually.
  ///
  /// In es, this message translates to:
  /// **'Elegir a mano'**
  String get voiceChooseManually;

  /// No description provided for @voicePrompt.
  ///
  /// In es, this message translates to:
  /// **'Hola, soy Sano. Cuéntame a qué alérgenos eres sensible. Puedes hablar o escribir.'**
  String get voicePrompt;

  /// No description provided for @voiceListening.
  ///
  /// In es, this message translates to:
  /// **'Escuchando… toca el micrófono al terminar'**
  String get voiceListening;

  /// No description provided for @voiceTapToSpeak.
  ///
  /// In es, this message translates to:
  /// **'Toca el micrófono y habla'**
  String get voiceTapToSpeak;

  /// No description provided for @voicePrivacy.
  ///
  /// In es, this message translates to:
  /// **'La voz se procesa en tu teléfono y no se envía a ningún servidor.'**
  String get voicePrivacy;

  /// No description provided for @voiceTypeHint.
  ///
  /// In es, this message translates to:
  /// **'O escribe aquí…'**
  String get voiceTypeHint;

  /// No description provided for @voiceMicLabel.
  ///
  /// In es, this message translates to:
  /// **'Micrófono'**
  String get voiceMicLabel;

  /// No description provided for @voiceDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de micrófono. Puedes escribir o elegir a mano.'**
  String get voiceDenied;

  /// No description provided for @voiceNoMatch.
  ///
  /// In es, this message translates to:
  /// **'No te escuché bien. Toca el micrófono e intenta de nuevo.'**
  String get voiceNoMatch;

  /// No description provided for @voiceOfflineUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Tu teléfono no tiene reconocimiento de voz sin conexión para este idioma. Escribe o elige a mano.'**
  String get voiceOfflineUnsupported;

  /// No description provided for @voiceUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El reconocimiento de voz no está disponible. Escribe o elige a mano.'**
  String get voiceUnavailable;

  /// No description provided for @voiceNothingFound.
  ///
  /// In es, this message translates to:
  /// **'No reconocí ningún alérgeno. Prueba otra vez o elige a mano.'**
  String get voiceNothingFound;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get saved;

  /// No description provided for @purchasePending.
  ///
  /// In es, this message translates to:
  /// **'Tu pago está pendiente. Pro se activará cuando la tienda lo confirme.'**
  String get purchasePending;

  /// No description provided for @purchaseNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta de la tienda no permite compras en este teléfono.'**
  String get purchaseNotAllowed;

  /// No description provided for @purchaseFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la compra. Inténtalo de nuevo.'**
  String get purchaseFailed;

  /// No description provided for @restoreNothing.
  ///
  /// In es, this message translates to:
  /// **'No encontramos una compra de Pro para restaurar en esta cuenta.'**
  String get restoreNothing;

  /// No description provided for @restoreFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos restaurar la compra. Revisa tu conexión e inténtalo de nuevo.'**
  String get restoreFailed;

  /// No description provided for @proWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya tienes SanoScan Pro.'**
  String get proWelcome;

  /// No description provided for @proAlreadyOwned.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes SanoScan Pro. Gracias por apoyar la app.'**
  String get proAlreadyOwned;

  /// No description provided for @proProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando…'**
  String get proProcessing;

  /// No description provided for @linkFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace.'**
  String get linkFailed;

  /// No description provided for @disclaimerTitle.
  ///
  /// In es, this message translates to:
  /// **'SanoScan no reemplaza a un profesional'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In es, this message translates to:
  /// **'SanoScan te ayuda a revisar etiquetas, pero no es un dispositivo médico. El reconocimiento de texto y la traducción pueden fallar. «No detectado» no significa seguro: revisa siempre la etiqueta física y, ante cualquier duda, consulta a tu médico o alergólogo.'**
  String get disclaimerBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get termsOfUse;

  /// No description provided for @contactSupport.
  ///
  /// In es, this message translates to:
  /// **'Escríbenos'**
  String get contactSupport;

  /// No description provided for @openSourceLicenses.
  ///
  /// In es, this message translates to:
  /// **'Licencias de código abierto'**
  String get openSourceLicenses;

  /// No description provided for @madeWithCare.
  ///
  /// In es, this message translates to:
  /// **'Hecho con cuidado para quienes leen cada etiqueta.'**
  String get madeWithCare;

  /// No description provided for @shareDiagnostics.
  ///
  /// In es, this message translates to:
  /// **'Enviar diagnósticos anónimos'**
  String get shareDiagnostics;

  /// No description provided for @shareDiagnosticsBody.
  ///
  /// In es, this message translates to:
  /// **'Errores y uso general de la app, sin tus fotos, alérgenos ni perfiles. Nos ayuda a arreglar fallos.'**
  String get shareDiagnosticsBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
