# Escáner de alérgenos

App Flutter que revisa la lista de ingredientes de una etiqueta y avisa si contiene algo del perfil de alérgenos del usuario, aunque la etiqueta esté en otro idioma. Todo ocurre en el teléfono: OCR, detección de idioma y traducción con ML Kit, sin servidor propio.

> "No detectado" no significa seguro. La etiqueta física siempre manda.

## Estructura

```text
allergen_workspace/
  pubspec.yaml            workspace de Dart y scripts de Melos
  apps/
    allergen_scanner/     la app
  packages/
    core_ocr/             OCR compartido con las siguientes apps
    core_billing/         cobros con RevenueCat
    core_i18n/            idiomas soportados
```

La app sigue clean architecture por funcionalidad (`features/<nombre>/{presentation,domain,data}`), con Riverpod para el estado y go_router para la navegación.

## Requisitos

- Flutter 3.44 o superior
- Melos: `dart pub global activate melos`
- Android SDK con la plataforma 37

## Comandos

Desde `allergen_workspace/`:

```bash
dart run melos bootstrap
dart run melos run analyze
dart run melos run test
```

Para correr la app en un Android conectado o un emulador:

```bash
cd allergen_workspace/apps/allergen_scanner
flutter run
```

## Avance

- [x] Semana 1, día 1: monorepo, esqueleto, tema y localización es/en
- [x] Semana 1, día 2: cámara, galería, permisos y recorte
- [x] Semana 1, día 3: OCR con ML Kit y bloques sobre la foto
- [x] Semana 1, día 4: detección de idioma, traducción y gestión de idiomas descargados
- [x] Semana 1, día 5: localizador de la lista de ingredientes, comparación tolerante a errores de OCR y banco de etiquetas reales (`apps/allergen_scanner/test_labels`)
- [x] Semana 2, día 1: `allergens.json` con 14 alérgenos UE + lactosa, sinónimos en 6 idiomas, códigos E/INS, frases de trazas y exclusiones
- [x] Semana 2, día 2: comparador (original + traducción, trazas, códigos INS, falsos amigos) y separación de ingredientes
- [x] Semana 2, día 3: diseño SanoScan aplicado (tema, 3 pestañas, mascota), perfiles con Drift, grilla de alérgenos y onboarding de 3 pasos
- [x] Diseño final SanoScan (`docs/design/DISENO_SANOSCAN.md`): tokens, barra flotante, iconos Lucide, Sano con estados y corona Pro
- [x] Onboarding con voz o texto, confirmación y elección a mano
- [x] Semana 2, día 4: escáner en vivo, procesando, resultado con tres niveles, resaltado sobre la foto, regla de calidad y aviso de seguridad
- [x] Semana 2, día 5: historial (Drift v2 con migración), filtros, límite gratis de 5 escaneos diarios y 30 días de historial
- [ ] Pasada completa con las etiquetas reales (`test_labels`)
- [ ] Semana 3: RevenueCat y Pro real, pulido, Crashlytics, ficha de tienda y release
