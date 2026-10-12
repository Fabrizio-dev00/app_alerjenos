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
  /// **'Escáner de alérgenos'**
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
  /// **'Escáner Pro'**
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
