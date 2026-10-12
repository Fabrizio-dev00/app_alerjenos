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
- [ ] Semana 1, día 4: detección de idioma y traducción
- [ ] Semana 1, día 5: extraer `core_ocr` y probar con etiquetas reales
