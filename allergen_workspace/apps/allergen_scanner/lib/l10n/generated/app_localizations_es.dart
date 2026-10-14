// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SanoScan';

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
  String get paywallTitle => 'SanoScan Pro';

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

  @override
  String get ocrTitle => 'Texto detectado';

  @override
  String get ocrReading => 'Leyendo la etiqueta…';

  @override
  String get ocrNoText =>
      'No encontramos texto. Prueba con más luz y con la lista de ingredientes bien enfocada.';

  @override
  String get ocrFailed => 'No pudimos leer la imagen. Inténtalo de nuevo.';

  @override
  String ocrBlocksFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bloques de texto detectados',
      one: '1 bloque de texto detectado',
    );
    return '$_temp0';
  }

  @override
  String get ocrTapHint => 'Toca un recuadro para ver el texto que leímos ahí.';

  @override
  String get ocrShowAllText => 'Ver todo el texto';

  @override
  String get ocrImageUnavailable => 'No se pudo mostrar la imagen.';

  @override
  String get settingsScanLanguages => 'Idiomas para escanear';

  @override
  String get settingsScanLanguagesSubtitle =>
      'Descarga tus idiomas antes de viajar';

  @override
  String get languagesIntro =>
      'Para traducir etiquetas sin internet, descarga el idioma de la etiqueta y el tuyo. Cada idioma ocupa unos 30 MB y se descarga una sola vez.';

  @override
  String get languageDownloaded => 'Descargado';

  @override
  String get languageNotDownloaded => 'No descargado';

  @override
  String get languageDownloading => 'Descargando…';

  @override
  String get languageDownload => 'Descargar';

  @override
  String get languageDelete => 'Eliminar';

  @override
  String languageDownloadFailed(String language) {
    return 'No pudimos descargar $language. Revisa tu conexión e inténtalo de nuevo.';
  }

  @override
  String get languagesLoadFailed =>
      'No pudimos revisar los idiomas descargados.';

  @override
  String detectedLanguage(String language) {
    return 'Idioma detectado: $language';
  }

  @override
  String translatedFrom(String from, String to) {
    return 'Traducido de $from a $to';
  }

  @override
  String get showOriginal => 'Original';

  @override
  String get showTranslation => 'Traducción';

  @override
  String translationModelMissing(String language) {
    return 'La etiqueta está en $language. Para traducirla sin internet descarga los idiomas que faltan (unos 30 MB cada uno).';
  }

  @override
  String get translationDownload => 'Descargar y traducir';

  @override
  String translationUnsupported(String code) {
    return 'El idioma de la etiqueta ($code) todavía no está soportado. Se muestra el texto original.';
  }

  @override
  String get translationFailed =>
      'No pudimos traducir. Se muestra el texto original.';

  @override
  String get languageUndetermined =>
      'No pudimos identificar el idioma del texto.';

  @override
  String get ingredientsFound => 'Lista de ingredientes encontrada';

  @override
  String get ingredientsNotFound =>
      'No encontramos la palabra «Ingredientes». Acerca la cámara a la lista o recorta solo esa parte para leerla mejor.';

  @override
  String get tagline => 'Lee la etiqueta. Cuida lo que comes.';

  @override
  String get onboardingIntro =>
      'Fotografía los ingredientes en cualquier idioma y SanoScan busca tus alérgenos al instante.';

  @override
  String get statLanguages => 'idiomas';

  @override
  String get statAccounts => 'cuentas';

  @override
  String get statOnDevice => 'en tu móvil';

  @override
  String get onboardingNoSignup => 'Sin registro, sin anuncios';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String onboardingStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get allergensQuestion => '¿Qué alérgenos evitas?';

  @override
  String get allergensSearch => 'Buscar alérgeno';

  @override
  String allergensSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elegidos.',
      one: '1 elegido.',
      zero: 'Ninguno elegido.',
    );
    return '$_temp0';
  }

  @override
  String get profileStoredLocally => 'Tu perfil se guarda solo en este móvil.';

  @override
  String get saveProfile => 'Guardar perfil';

  @override
  String get onboardingReadyTitle => 'Antes de empezar';

  @override
  String get onboardingReadyBody =>
      'SanoScan te ayuda a revisar etiquetas, pero el reconocimiento de texto puede fallar.';

  @override
  String get onboardingReadyRule =>
      '«No detectado» no significa seguro. Revisa siempre la etiqueta física.';

  @override
  String get onboardingLanguagesHint =>
      '¿Vas a viajar? Descarga los idiomas de las etiquetas en Ajustes para traducir sin internet.';

  @override
  String get onboardingAccept => 'Entendido, empezar';

  @override
  String get defaultProfileName => 'Yo';

  @override
  String get allergenMilk => 'Leche';

  @override
  String get allergenEggs => 'Huevo';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenPeanuts => 'Maní';

  @override
  String get allergenTreeNuts => 'Frutos secos';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenFish => 'Pescado';

  @override
  String get allergenShellfish => 'Mariscos';

  @override
  String get allergenSesame => 'Ajonjolí';

  @override
  String get allergenMustard => 'Mostaza';

  @override
  String get allergenCelery => 'Apio';

  @override
  String get allergenSulphites => 'Sulfitos';

  @override
  String get allergenLactose => 'Lactosa';

  @override
  String get allergenLupin => 'Tarwi (altramuz)';

  @override
  String get allergensNone => 'Sin alérgenos elegidos';

  @override
  String get activeProfile => 'Perfil activo';

  @override
  String get profilesTitle => 'Perfiles';

  @override
  String get addProfile => 'Agregar perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get newProfile => 'Nuevo perfil';

  @override
  String get profileName => 'Nombre del perfil';

  @override
  String get profileNameRequired => 'Escribe un nombre';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String deleteProfileConfirm(String name) {
    return '¿Eliminar el perfil $name? No se puede deshacer.';
  }

  @override
  String get profileActiveBadge => 'Activo';

  @override
  String get useProfile => 'Usar este perfil';

  @override
  String scanProfile(String name) {
    return 'Perfil: $name';
  }

  @override
  String get proBannerTitle => 'SanoScan Pro';

  @override
  String get proBannerSubtitle => 'Sin límite de escaneos · USD 3.99 una vez';

  @override
  String get profilesProHint =>
      'Con Pro puedes tener hasta 6 perfiles para toda la familia.';

  @override
  String settingsOfflineReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listos',
      one: '1 listo',
      zero: 'Ninguno',
    );
    return '$_temp0';
  }

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String allergenPossible(String name) {
    return '$name (posible)';
  }

  @override
  String allergenTraces(String name) {
    return '$name (trazas)';
  }

  @override
  String get possibleHint =>
      'El ingrediente no dice su origen. Revisa la etiqueta.';

  @override
  String get cameraGrant => 'Dar permiso';

  @override
  String get cameraNeededTitle => 'Necesitamos tu cámara';

  @override
  String get cameraNeededBody =>
      'SanoScan la usa solo para leer etiquetas. La foto no sale de tu teléfono.';

  @override
  String get checkedTitle => 'Lo que revisamos';

  @override
  String checkedIngredients(int count, String language) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leímos $count ingredientes en $language',
      one: 'Leímos 1 ingrediente en $language',
    );
    return '$_temp0';
  }

  @override
  String get checkedBothTexts => 'Comparamos el texto original y el traducido';

  @override
  String get checkedOriginal => 'Revisamos el texto original';

  @override
  String get checkedQuality => 'Calidad de lectura: buena';

  @override
  String get confirmTitle => '¿Es esto correcto?';

  @override
  String confirmUnderstood(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Entendí $count alérgenos. Si falta uno o sobra otro, tócalo para corregir.',
      one:
          'Entendí 1 alérgeno. Si falta uno o sobra otro, tócalo para corregir.',
    );
    return '$_temp0';
  }

  @override
  String get confirmYouSaid => 'Lo que dijiste';

  @override
  String get confirmAddAnother => 'Añadir otro alérgeno';

  @override
  String get confirmReviewNote =>
      'Revisa la lista. SanoScan solo buscará estos alérgenos en las etiquetas.';

  @override
  String get confirmSave => 'Sí, guardar mi perfil';

  @override
  String get confirmSpeakAgain => 'Hablar otra vez';

  @override
  String get confirmFixManually => 'Corregir a mano';

  @override
  String get editMyAllergens => 'Editar mis alérgenos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterTraces => 'Trazas';

  @override
  String get historyEmptyTitle => 'Aún no hay escaneos';

  @override
  String get historyEmptyBody =>
      'Cuando escanees una etiqueta, aparecerá aquí. Solo se guarda en tu móvil.';

  @override
  String get historyFilterEmpty => 'No hay escaneos con este resultado.';

  @override
  String get scanFirstLabel => 'Escanear mi primera etiqueta';

  @override
  String get langEs => 'español';

  @override
  String get langEn => 'inglés';

  @override
  String get langFr => 'francés';

  @override
  String get langDe => 'alemán';

  @override
  String get langIt => 'italiano';

  @override
  String get langPt => 'portugués';

  @override
  String get langJa => 'japonés';

  @override
  String get langKo => 'coreano';

  @override
  String get langZh => 'chino';

  @override
  String get langNl => 'neerlandés';

  @override
  String get langUnknown => 'idioma desconocido';

  @override
  String limitTitle(int count) {
    return 'Llegaste a $count escaneos hoy';
  }

  @override
  String get limitBody =>
      'Vuelve mañana o pasa a Pro para escanear sin límites.';

  @override
  String get seePro => 'Ver SanoScan Pro';

  @override
  String get seeHistory => 'Ver historial';

  @override
  String listAnd(String first, String last) {
    return '$first y $last';
  }

  @override
  String get noAllergensTitle => 'Elige tus alérgenos';

  @override
  String get noAllergensBody =>
      'Tu perfil no tiene alérgenos. Elige al menos uno para empezar a escanear.';

  @override
  String originalIn(String language) {
    return 'Original ($language)';
  }

  @override
  String translatedIn(String language) {
    return 'Traducido ($language)';
  }

  @override
  String get readText => 'Texto leído';

  @override
  String readIn(String language) {
    return 'Leído en $language';
  }

  @override
  String readInTranslated(String source, String target) {
    return 'Leído en $source, traducido al $target';
  }

  @override
  String get photoStaysOnPhone => 'Tu foto no sale del teléfono';

  @override
  String get privacyNoAccount =>
      'No necesitas cuenta ni registro. SanoScan no sabe quién eres.';

  @override
  String get privacyOnDevice =>
      'Tus perfiles, alérgenos e historial se guardan solo en este teléfono.';

  @override
  String get privacyVoice =>
      'La voz se reconoce en el teléfono y no se envía a ningún servidor.';

  @override
  String get privacyPhotos =>
      'Las fotos se leen en el teléfono. Solo se guardan si guardas el escaneo en el historial.';

  @override
  String get privacyMetrics =>
      'Solo se registran errores y métricas anónimas para mejorar la app, nunca tus fotos ni tus alérgenos.';

  @override
  String get proTagline => 'Escanea sin límites, cuida a toda tu familia.';

  @override
  String get proFree => 'Gratis';

  @override
  String get proRowScans => 'Escaneos al día';

  @override
  String get proRowLanguages => '6 idiomas sin conexión';

  @override
  String get proUnlimited => 'Sin límite';

  @override
  String get proUpToSix => 'Hasta 6';

  @override
  String get proThirtyDays => '30 días';

  @override
  String get proForever => 'Siempre';

  @override
  String get yes => 'Sí';

  @override
  String get proOneTime => 'pago único. Sin suscripción.';

  @override
  String proUnlock(String price) {
    return 'Desbloquear Pro por $price';
  }

  @override
  String get proRestore => 'Restaurar compra';

  @override
  String get proNotNow => 'Ahora no';

  @override
  String get proStoreNote =>
      'El pago se hace en la tienda de tu móvil. No necesitas crear una cuenta.';

  @override
  String get purchaseNotReady =>
      'Las compras se activan antes del lanzamiento.';

  @override
  String get proActive => 'Activo';

  @override
  String get proActiveBody => 'Compra única. Escaneos y perfiles sin límite.';

  @override
  String profileDefaultName(int number) {
    return 'Perfil $number';
  }

  @override
  String profilesCount(int count, int max) {
    return '$count de $max';
  }

  @override
  String profilesIntro(int count, int max) {
    return '$count de $max perfiles. Cada persona tiene sus propios alérgenos.';
  }

  @override
  String get profilesNote =>
      'El perfil activo es el que usa el escáner. Los alérgenos de cada perfil se guardan solo en este teléfono.';

  @override
  String quotaRemaining(int remaining, int total) {
    return 'Te quedan $remaining de $total escaneos hoy ·';
  }

  @override
  String resultContainsSubtitle(int count, String profile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alérgenos de tu perfil $profile',
      one: '1 alérgeno de tu perfil $profile',
    );
    return '$_temp0';
  }

  @override
  String resultTracesSubtitle(int count, String profile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'El fabricante avisa de posible contaminación cruzada con $count alérgenos de tu perfil $profile.',
      one:
          'El fabricante avisa de posible contaminación cruzada con 1 alérgeno de tu perfil $profile.',
    );
    return '$_temp0';
  }

  @override
  String resultNotDetectedSubtitle(String profile) {
    return 'No encontramos alérgenos de tu perfil $profile en el texto que leímos.';
  }

  @override
  String get sanoName => 'Sano';

  @override
  String get save => 'Guardar';

  @override
  String get saveScanTitle => 'Guardar en el historial';

  @override
  String get saveScanHint => 'Nombre del producto (opcional)';

  @override
  String get savedToHistory => 'Guardado en el historial';

  @override
  String get scanAnother => 'Escanear otra';

  @override
  String get scannerHint => 'Acerca la etiqueta y toca';

  @override
  String get settingsOfflineLanguages => 'Idiomas sin conexión';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsPrivacyValue => 'Solo en tu móvil';

  @override
  String get settingsSaveHistory => 'Guardar historial';

  @override
  String get settingsVibrate => 'Vibración al escanear';

  @override
  String get stepReading => 'Leyendo el texto…';

  @override
  String get stepRead => 'Texto leído';

  @override
  String stepReadLanguage(String language) {
    return 'Texto leído · $language detectado';
  }

  @override
  String stepTranslating(String language) {
    return 'Traduciendo al $language…';
  }

  @override
  String stepTranslated(String language) {
    return 'Traducido al $language';
  }

  @override
  String stepAlreadyIn(String language) {
    return 'Ya está en $language';
  }

  @override
  String stepModelMissing(String language) {
    return 'Sin traducción: falta descargar $language';
  }

  @override
  String get stepOriginalOnly => 'Se revisa el texto original';

  @override
  String get stepMatching => 'Buscando tus alérgenos…';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get unnamedScan => 'Escaneo sin nombre';

  @override
  String get unreadableTitle => 'No pudimos leer la etiqueta';

  @override
  String get unreadableBody =>
      'Acerca la etiqueta, mejora la luz y evita los reflejos.';

  @override
  String get voiceChooseManually => 'Elegir a mano';

  @override
  String get voicePrompt =>
      'Hola, soy Sano. Cuéntame a qué alérgenos eres sensible. Puedes hablar o escribir.';

  @override
  String get voiceListening => 'Escuchando… toca el micrófono al terminar';

  @override
  String get voiceTapToSpeak => 'Toca el micrófono y habla';

  @override
  String get voicePrivacy =>
      'La voz se procesa en tu teléfono y no se envía a ningún servidor.';

  @override
  String get voiceTypeHint => 'O escribe aquí…';

  @override
  String get voiceMicLabel => 'Micrófono';

  @override
  String get voiceDenied =>
      'Sin permiso de micrófono. Puedes escribir o elegir a mano.';

  @override
  String get voiceNoMatch =>
      'No te escuché bien. Toca el micrófono e intenta de nuevo.';

  @override
  String get voiceOfflineUnsupported =>
      'Tu teléfono no tiene reconocimiento de voz sin conexión para este idioma. Escribe o elige a mano.';

  @override
  String get voiceUnavailable =>
      'El reconocimiento de voz no está disponible. Escribe o elige a mano.';

  @override
  String get voiceNothingFound =>
      'No reconocí ningún alérgeno. Prueba otra vez o elige a mano.';

  @override
  String get saved => 'Guardado';
}
