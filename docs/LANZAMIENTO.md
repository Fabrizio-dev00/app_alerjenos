# SanoScan: guía de lanzamiento

Lo que ya está en el código y lo que tienes que hacer tú (cuentas, claves y publicación). Hazlo en este orden.

## 1. Google Play Console

1. Crea la cuenta en <https://play.google.com/console> (USD 25, pago único).
2. Crea la app **SanoScan** con el paquete **`dev.fabrizio.sanoscan`**. Este identificador no se puede cambiar después de publicar.
3. En **Monetizar > Productos > Productos integrados en la app**, crea el producto:
   - ID: `sanoscan_pro`
   - Tipo: **no consumible** (pago único)
   - Precio: USD 3.99 (Play convierte a moneda local)

## 2. RevenueCat (cobros)

1. Crea una cuenta gratis en <https://app.revenuecat.com> y un proyecto **SanoScan**.
2. Agrega la app de Google Play con el paquete `dev.fabrizio.sanoscan` y conecta la cuenta de servicio de Play Console (RevenueCat explica cómo en ese paso).
3. **Entitlements:** crea uno con identificador **`pro`** y asígnale el producto `sanoscan_pro`.
4. **Offerings:** crea la oferta por defecto (*current*) con un paquete **Lifetime** que tenga `sanoscan_pro`.
5. Copia la **clave pública de Android** (empieza con `goog_`).

La clave se pasa al compilar, no se guarda en el código:

```bash
flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=goog_xxxxx
```

Sin la clave, la app funciona en modo gratis y "Desbloquear Pro" avisa que las compras se activan antes del lanzamiento.

**Probar la compra de punta a punta:** en Play Console agrega tu correo como *tester de licencias* (Configuración > Pruebas de licencias). Así puedes comprar sin que se cobre de verdad.

## 3. Firebase (Crashlytics y Analytics anónimos)

1. Crea un proyecto en <https://console.firebase.google.com>. Puedes desactivar Google Analytics para anuncios.
2. Agrega una app Android con el paquete `dev.fabrizio.sanoscan`.
3. Descarga `google-services.json` y ponlo en `allergen_workspace/apps/allergen_scanner/android/app/`.
4. Activa **Crashlytics** en la consola.

Con ese archivo presente, el build activa Firebase solo. Sin él, la app compila y funciona sin telemetría. El archivo está en `.gitignore`; guarda una copia segura.

Qué se envía, y solo si el usuario no lo desactiva en Ajustes > Privacidad: errores y los eventos `onboarding_completed`, `scan_completed` (tipo de resultado, si hubo traducción, idioma), `scan_unreadable`, `pro_purchased` y `pro_restored`. **Nunca** alérgenos, perfiles, fotos ni texto de etiquetas. En modo debug no se envía nada.

## 4. Firma de la app (keystore)

Genera la llave una sola vez y **guárdala en un lugar seguro**. Si la pierdes, no podrás publicar actualizaciones.

```bash
keytool -genkey -v -keystore C:\Users\USUARIO.DESKTOP-O8B05DQ\sanoscan-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sanoscan
```

Crea `allergen_workspace/apps/allergen_scanner/android/key.properties` (ya está en `.gitignore`):

```properties
storePassword=TU_CLAVE
keyPassword=TU_CLAVE
keyAlias=sanoscan
storeFile=C:\\Users\\USUARIO.DESKTOP-O8B05DQ\\sanoscan-upload.jks
```

Sin `key.properties`, el build de release se firma con la llave de debug (sirve para probar, no para subir a Play).

## 5. Política de privacidad y términos (GitHub Pages)

1. Antes de publicar, reemplaza `[correo de contacto]` en `docs/privacidad.html` y `docs/terminos.html` por tu correo de soporte.
2. En GitHub: **Settings > Pages > Source: Deploy from a branch**, rama `main`, carpeta `/docs`.
3. Quedan en:
   - <https://fabrizio-dev00.github.io/app_alerjenos/privacidad.html>
   - <https://fabrizio-dev00.github.io/app_alerjenos/terminos.html>

Esas URLs ya están en la pantalla "Acerca de" de la app. El correo de soporte se muestra en la app si compilas con `--dart-define=SUPPORT_EMAIL=tu@correo.com`.

## 6. Build de release

Desde `allergen_workspace/apps/allergen_scanner`:

```bash
flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=goog_xxxxx --dart-define=SUPPORT_EMAIL=tu@correo.com
```

El archivo para subir queda en `build/app/outputs/bundle/release/app-release.aab`.

## 7. Prueba cerrada (obligatoria para cuentas personales nuevas)

1. En Play Console: **Pruebas > Prueba cerrada**. Sube el `.aab` y crea una lista con **al menos 12 testers** (sus correos de Google).
2. Deben tenerla instalada **14 días seguidos** antes de que puedas pedir la producción.
3. Mientras tanto, revisa Crashlytics y corrige lo que aparezca.

## 8. Ficha de la tienda

Textos listos en `docs/store/ficha_play_store.md` (es y en), con las respuestas del formulario de seguridad de datos. Necesitas además:

- Ícono 512×512: usa `allergen_workspace/apps/allergen_scanner/assets/brand/icon.png` (se puede reducir).
- Imagen destacada 1024×500 y al menos 2 capturas del teléfono.

## 9. Lanzamiento

Producción con **lanzamiento por etapas** del 10 al 20 %. Sube al 100 % cuando Crashlytics esté limpio.

## Lista final antes de publicar

- [ ] Cero falsos negativos en las etiquetas de prueba (`test_labels`, `tool/run_label_benchmark.ps1`).
- [ ] Funciona sin internet con los idiomas descargados.
- [ ] Compra probada de punta a punta con un tester de licencias, y "Restaurar compra" probado.
- [ ] El aviso "No detectado no significa seguro" visible en los tres resultados.
- [ ] Política de privacidad publicada en una URL real, con tu correo.
- [ ] Probada en un Android de gama baja, en modo avión y con la cámara negada.
