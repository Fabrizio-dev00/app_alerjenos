# SanoScan: guía de diseño para construir en Flutter

Documento de traspaso. Acompaña a PLAN_ESCANER_ALERGENOS.md (arquitectura, paquetes, plan por días). Si algo se contradice, esta guía manda en lo visual y el plan manda en la arquitectura.

Referencia visual: lienzo "SanoScan v3: app completa" (16 pantallas). Exporta capturas del lienzo y ponlas en `docs/design/` para consultarlas.

## 1. Reglas que no se pueden romper

1. Nunca usar verde para "No detectado".
2. Nunca escribir la palabra "seguro" salvo negada en el aviso fijo: "No detectado no significa seguro. Revisa siempre la etiqueta física."
3. Ese aviso aparece en los tres resultados.
4. Cada resultado se distingue por color, icono y forma a la vez:
   - Contiene: rojo #C4161C, círculo con X, píldora rellena.
   - Puede contener trazas: ámbar #A55A00 sobre #FFF0D6, triángulo de advertencia, borde punteado.
   - No detectado: contorno negro #2A160A sobre #FFFDF8, lupa con check, sin relleno.
5. La mascota no celebra ni se ve aliviada en "No detectado". Se ve atenta y neutra.
6. Sin cuenta ni login. Perfil de alérgenos, historial y fotos se quedan en el teléfono. La voz se procesa en el dispositivo.
7. Texto mínimo 14 px, cuerpo 16 a 18 px, áreas táctiles de al menos 48 px.
8. Respetar "reducir movimiento" (`MediaQuery.disableAnimationsOf`): sin animaciones de movimiento, solo cambios de opacidad o de expresión.

## 2. Tokens

### Color
| Token | Hex | Uso |
|---|---|---|
| brandOrange | #EA6113 | inicio del degradado |
| brandTangerine | #F88F22 | medio del degradado, formas de la mascota |
| brandAmber | #FBB931 | fin del degradado |
| brandCream | #FFE3B3 | fichas suaves, texto sobre fondo oscuro |
| bg | #FFF1D9 | fondo de pantallas |
| surface | #FFFDF8 | tarjetas y hojas |
| ink | #2A160A | texto principal, bordes fuertes, fondos oscuros |
| inkSoft | #5B4A40 | texto secundario |
| accentText | #A83F00 | enlaces y texto de acento sobre claro (contraste 4.5+) |
| danger | #C4161C | Contiene |
| warn | #A55A00 / #FFF0D6 | Trazas |
| hairline | rgba(42,22,10,.14) | bordes finos |

Degradado de marca: `LinearGradient(begin: centerLeft, end: centerRight, colors: [#EA6113, #F88F22, #FBB931])`. Texto sobre el degradado: siempre #2A160A, nunca blanco.

El degradado nunca se usa en un veredicto de resultado. Es solo cromo de la app: botones principales, pestaña activa, interruptores, cabecera de bienvenida, burbuja del usuario, botón del micrófono.

Pantallas oscuras (escáner, procesando, cabeceras de resultado): fondo #2A160A con un radial #3A2F2A arriba. Pro usa radial #7A3A12 a #2A160A.

### Tipografía
- Familia: fuente del sistema (SF Pro en iOS, Roboto en Android). En diseño se ve con Inter. En Flutter, usar la fuente por defecto de la plataforma.
- Veredicto 28 bold. Título grande 34 bold, tracking -0.02em. Nombre de alérgeno 18 bold. Cuerpo 16 a 18. Secundario y avisos 14 (mínimo).

### Forma y sombra
- Botones: altura 56, radio 28 (píldora). Pulsado: escala 0.97, 120 ms.
- Tarjetas: radio 22 a 24. Fichas de alérgeno: 100 de alto, radio 22. Hojas inferiores: radio 36 arriba, grabber de 44x5.
- Sombra suave estándar: `0 1px 2px rgba(42,22,10,.06), 0 8px 24px rgba(42,22,10,.10)`. Sombra de botón de marca: `0 8px 24px rgba(234,97,19,.35)`.
- Rejilla de 8 px. Márgenes laterales de 20 a 24.

## 3. Componentes y su equivalente en Flutter

| Componente | Widget sugerido |
|---|---|
| Título grande que se encoge | `CupertinoSliverNavigationBar` o `SliverAppBar.large` |
| Lista agrupada (Ajustes) | `CupertinoListSection.insetGrouped` con `CupertinoListTile` |
| Interruptor | `CupertinoSwitch` con `activeTrackColor` del degradado (o `Switch.adaptive`) |
| Control segmentado (filtro del Historial) | `CupertinoSlidingSegmentedControl` |
| Barra de pestañas flotante de vidrio | `Stack` + `ClipRRect` + `BackdropFilter(ImageFilter.blur(24,24))`, alto 72, radio 36, margen 16. 3 pestañas: Escanear, Historial, Ajustes. Activa: fondo naranja al 16% y texto #B84A00 |
| Hoja de resultado | `showModalBottomSheet` o `DraggableScrollableSheet` |
| Ficha de alérgeno | Widget propio `AllergenChip` (seleccionada: degradado, insignia con check) |
| Botón principal | Widget propio `BrandButton` con `DecoratedBox` degradado |
| Indicador de pasos | 3 puntos, el activo alargado (28x8) |

## 4. Mapa de pantallas y flujo

| # | Archivo del lienzo | Pantalla | Salidas |
|---|---|---|---|
| 1 | Main | Bienvenida | Comenzar a 2 |
| 2 | AlergenosVoz | Contar alérgenos (voz o texto) | Micrófono a 3, Elegir a mano a 4 |
| 3 | AlergenosConfirmar | Confirmar lo que entendió Sano | Guardar a 5, Corregir a mano o Añadir a 4, Hablar otra vez a 2 |
| 4 | Alergenos | Elegir alérgenos a mano | Guardar perfil a 5 |
| 5 | Escaner | Escáner | Captura a 6, pill de escaneos a Pro |
| 6 | Procesando | Procesando | Resultado según análisis |
| 7a | ResultadoContiene | Resultado: Contiene | Guardar a 8, Escanear otra a 5 |
| 7b | ResultadoTrazas | Resultado: Puede contener trazas | igual |
| 7c | ResultadoNoDetectado | Resultado: No detectado | igual |
| 8 | Historial | Historial con filtro | Fila a su resultado |
| 9 | Ajustes | Ajustes (plan gratis) | Perfil a 4, banner a 10 |
| 9b | AjustesPro | Ajustes con Pro activo | Perfiles a 9c |
| 9c | Perfiles | Lista de perfiles (Pro) | Añadir perfil a 2, tocar perfil a 4 |
| 10 | Pro | SanoScan Pro | Comprar a 9b, Restaurar a 9b |
| 11 | Estados | Cámara denegada, no se pudo leer, límite diario, historial vacío | según tarjeta |
| 0 | Marca | Tablero de marca y sistema | referencia |

Rutas con go_router: `/welcome`, `/onboarding/voice`, `/onboarding/confirm`, `/onboarding/manual`, `/scan`, `/processing`, `/result/:id`, `/history`, `/settings`, `/settings/profiles`, `/pro`. Tras el onboarding completo, la app abre directo en `/scan`.

## 5. Detalle por pantalla

**Bienvenida.** Cabecera degradada con curva y líneas orgánicas en crema. Mascota con balanceo. Titular "Lee la etiqueta. Cuida lo que comes." Tres datos: 6 idiomas, 0 cuentas, 100% en tu móvil. Botón "Comenzar".

**Contar alérgenos.** Sano grande con tres anillos que se expanden. Burbuja de Sano, burbuja naranja del usuario con la transcripción en vivo, onda de 9 barras, campo "O escribe aquí…" y micrófono de 64 px que late. Línea de privacidad con candado. Enlace "Elegir a mano".

**Confirmar.** Sano contento, frase original entre comillas, tres fichas detectadas con iconos, botón "Añadir otro alérgeno" con borde punteado, aviso de revisión, "Sí, guardar mi perfil".

**Elegir a mano.** Título grande, buscador estilo iOS, cuadrícula de 3 columnas y 12 alérgenos con icono. Seleccionada: degradado, texto oscuro y check animado (pop 320 ms). Contador "3 elegidos" y botón "Guardar perfil".

**Escáner.** Vista de cámara oscura, pill de perfil arriba a la izquierda, linterna a la derecha, pill del plan gratis "Te quedan 3 de 5 escaneos hoy" (en Pro no se muestra), marco con esquinas, línea de escaneo, botón de captura de 88 px, galería, barra de pestañas.

**Procesando.** Foto congelada con barrido, hoja inferior con Sano pensando, tres pasos (texto leído, traducido, buscando alérgenos) con checks que se dibujan y esqueleto con shimmer.

**Resultados.** Foto arriba con curva oscura. Hoja con veredicto, filas por alérgeno (icono del alérgeno con insignia X o triángulo), original y traducido lado a lado, aviso fijo, botones. En No detectado se añade "Lo que revisamos" con tres checks y el aviso en bloque oscuro.

**Historial.** Control segmentado, filas agrupadas por HOY y AYER con icono, nombre, hora e idioma, y píldora del veredicto.

**Ajustes.** Perfil activo, banner de Pro, lista agrupada con iconos blancos sobre cuadros naranja, interruptores "Guardar historial" y "Vibración al escanear".

**Pro.** Fondo oscuro con resplandor, tabla Gratis contra Pro (5 escaneos al día contra sin límite, 1 perfil contra hasta 6, historial 30 días contra siempre, 6 idiomas offline en ambos), precio USD 3.99 pago único, "Desbloquear Pro", "Restaurar compra", "Ahora no". La fila de historial es una propuesta: confirmar antes de implementarla.

## 6. Estados Gratis y Pro

| | Gratis | Pro |
|---|---|---|
| Escaneos | 5 por día, contador en el escáner | sin límite, sin contador |
| Perfiles | 1 | hasta 6, pantalla Perfiles |
| Ajustes | banner de compra | tarjeta oscura "Pro activo" |
| Compra | RevenueCat (`purchases_flutter`), pago único, restaurar | entitlement `pro` |

## 7. Movimiento

- Línea de escaneo: 1.6 s en bucle, ease-in-out, alternando.
- Hoja de resultado: sube 320 a 420 ms, curva `Cubic(.22, 1, .36, 1)`.
- Filas de resultado: entran escalonadas 100 ms.
- Ficha seleccionada: pop con `Cubic(.34, 1.56, .64, 1)`, 320 ms.
- Interruptor: la bolita con resorte, 420 ms.
- Checks: se dibujan en 360 ms.
- Error: sacudida de 600 ms.
- Pestañas: 220 ms.
- Con reducir movimiento, todo lo anterior pasa a cambio de opacidad.

## 8. Mascota Sano

Es una etiqueta con piernas: cuerpo crema con borde ink, agujero superior, líneas naranja de ingredientes, zapatos naranja, mejillas rosadas.

Estados para implementar (Rive si se llega, CustomPainter para el MVP):

| Estado | Dónde | Cara |
|---|---|---|
| idle | Bienvenida | sonrisa, balanceo suave |
| escuchando | Contar alérgenos | boca abierta, anillos |
| contento | Confirmar | sonrisa |
| pensando | Procesando | boca recta, balanceo rápido |
| sorprendido | cámara denegada | boca "o" |
| confundido | no se pudo leer | boca ondulada |
| sueño | límite diario | ojos cerrados |
| atento | resultados | neutra. Nunca celebra en No detectado |

**Sano Pro.** Cuando el entitlement `pro` está activo, Sano lleva una corona dorada (#FBB931, borde ink, tres joyas naranja, inclinada 6 grados) en todas sus apariciones: contar alérgenos, confirmar, procesando, estados vacíos y la tarjeta "Pro activo" de Ajustes. Al comprar, se anima un momento en que Sano se pone la corona (caída con rebote de 420 ms). En la pantalla de compra ya se muestra con corona como premio. Sin Pro, sin corona. Ver el tablero de marca para las dos versiones.

## 9. Iconos

Librería Lucide (`lucide_icons_flutter`) o SVG exportados con `flutter_svg`. Grosor 2.

| Alérgeno | Icono |
|---|---|
| Leche | milk |
| Huevo | egg |
| Gluten | wheat |
| Cacahuate | bean |
| Frutos secos | nut |
| Soja | sprout |
| Pescado | fish |
| Mariscos | shell |
| Ajonjolí | cookie |
| Mostaza | droplet |
| Apio | leaf |
| Sulfitos | wine |

Otros: mic, keyboard, lock, info, check, plus, users, star, quote, chevron-left.

## 10. Voz y texto en el onboarding

- Reconocimiento: `speech_to_text` con preferencia por modo sin conexión.
- Interpretación: el mismo diccionario de alérgenos en 6 idiomas que usa el escáner, con sinónimos regionales (maní, cacahuate, cacahuete). Sin IA en la nube en el MVP.
- La lista detectada siempre se confirma en la pantalla 3 antes de guardarse.
- Si el usuario no elige ningún alérgeno, el escáner no se activa y muestra un aviso.

## 11. Orden de construcción sugerido

1. Día 1: monorepo Melos, tema (tokens de arriba), localización es/en, go_router con las rutas, barra de pestañas flotante.
2. Pantallas estáticas de onboarding (1, 2, 3, 4) con perfil guardado en local.
3. Escáner y flujo OCR, traducción, comparación (pantallas 5, 6, 7).
4. Historial y Ajustes (8, 9).
5. Pro y RevenueCat (10, 9b, 9c).
6. Estados de error (11) y mascota animada.

Entregar cada paso con la app compilando y con capturas comparables al lienzo.
