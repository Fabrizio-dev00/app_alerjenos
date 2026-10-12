// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Escáner de alérgenos';

  @override
  String get navScan => 'Escanear';

  @override
  String get navHistory => 'Historial';

  @override
  String get navProfiles => 'Perfiles';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get scanHeadline => 'Revisa una etiqueta';

  @override
  String get scanDescription =>
      'Toma una foto de la lista de ingredientes y te ayudamos a revisar si tiene algo de tu perfil.';

  @override
  String get scanTakePhoto => 'Tomar foto';

  @override
  String get scanFromGallery => 'Elegir de la galería';

  @override
  String get safetyNotice =>
      '\"No detectado\" no significa seguro. El reconocimiento de texto puede fallar: la etiqueta física siempre manda.';

  @override
  String get historyEmpty => 'Aún no tienes escaneos.';

  @override
  String get profilesEmpty => 'Crea tu perfil para elegir tus alérgenos.';

  @override
  String get settingsLanguage => 'Idioma de la app';

  @override
  String get settingsLanguageSystem => 'Usar el del sistema';

  @override
  String get paywallTitle => 'Escáner Pro';

  @override
  String get paywallDescription =>
      'Escaneos ilimitados y perfiles para toda la familia con un solo pago.';

  @override
  String get resultContains => 'Contiene';

  @override
  String get resultMayContain => 'Puede contener trazas';

  @override
  String get resultNotDetected => 'No detectado';

  @override
  String get cameraDenied =>
      'Necesitamos la cámara para leer la etiqueta. También puedes elegir una foto de la galería.';

  @override
  String get cameraBlocked =>
      'El permiso de cámara está bloqueado. Actívalo en los ajustes del teléfono.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get retry => 'Reintentar';

  @override
  String get galleryFailed =>
      'No pudimos abrir la galería. Inténtalo de nuevo.';

  @override
  String get cropFailed => 'No pudimos recortar la imagen. Inténtalo de nuevo.';

  @override
  String get cropTitle => 'Recorta los ingredientes';

  @override
  String get cameraUnavailable =>
      'No encontramos una cámara disponible en este dispositivo.';

  @override
  String get cameraFailed => 'No pudimos usar la cámara. Inténtalo de nuevo.';

  @override
  String get cameraHint => 'Encuadra la lista de ingredientes con buena luz';

  @override
  String get torchOn => 'Encender linterna';

  @override
  String get torchOff => 'Apagar linterna';

  @override
  String get previewTitle => 'Revisa la foto';

  @override
  String get previewHint =>
      'Comprueba que la lista de ingredientes se lea completa y nítida.';

  @override
  String get previewAnalyze => 'Analizar etiqueta';

  @override
  String get previewRetake => 'Usar otra foto';

  @override
  String get previewImageMissing =>
      'No encontramos la imagen. Vuelve a tomar la foto.';
}
