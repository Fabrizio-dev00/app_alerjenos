# SanoScan: sistema de diseño

Fuente de verdad visual de la app. Las pantallas de referencia están en `mockups/`.

**Nombre:** SanoScan
**Lema:** Lee la etiqueta. Cuida lo que comes.
**Mascota:** Sano, una etiqueta con cara, con variantes para cada estado (feliz, sorprendida, preocupada, neutra, pensando).

## Paleta

| Token | Nombre | Hex | Uso |
| --- | --- | --- | --- |
| `orange` | Naranja | `#EA6113` | Marca, inicio del degradado |
| `tangerine` | Mandarina | `#F88F22` | Degradado medio |
| `amber` | Ámbar | `#FBB931` | Fin del degradado |
| `cream` | Crema | `#FFE3B3` | Fondos suaves, círculos de iniciales |
| `coffee` | Café oscuro | `#2A160A` | Texto principal, fondos oscuros (cámara, paywall) |
| `contains` | Contiene | `#C4161C` | Veredicto "Contiene" |
| `traces` | Trazas | `#A55A00` | Veredicto "Puede contener trazas" (borde punteado) |

Botones principales: degradado naranja → mandarina → ámbar con texto café oscuro.

## Tipografía

- Títulos y veredictos: SF Pro Display, con Inter como respaldo.
- Texto y avisos: SF Pro Text, con un mínimo de 14 px.
- **En Android se usa Inter.** La licencia de SF Pro solo permite usarla en plataformas de Apple, así que no se empaqueta en la app.

## Veredictos

Cada uno combina color, icono y forma a la vez, nunca solo el color:

| Nivel | Estilo |
| --- | --- |
| Contiene | Píldora roja `#C4161C` rellena, icono ⊗ |
| Puede contener trazas | Píldora con borde punteado `#A55A00`, icono ⚠ |
| No detectado | Píldora con borde café, icono de lupa con check |

**Nunca verde y nunca la palabra "seguro".**

## Pantallas

1. **Onboarding** en 3 pasos: bienvenida, alérgenos que evitas y un tercer paso aún por definir. Tiene un selector de idioma "ES" arriba.
2. **Escanear** (pestaña): cámara en vivo con marco guía, selector de perfil, linterna, galería, botón de captura y modo "Auto".
3. **Leyendo la etiqueta:** hoja con pasos (texto leído e idioma detectado, traducido, buscando tus alérgenos) y el texto "Tu foto no sale del teléfono".
4. **Resultado:** veredicto, alérgenos con la evidencia "original → traducido", tarjetas de original y traducido, "Lo que revisamos" (con la calidad de lectura), aviso de seguridad, y los botones Guardar y Escanear otra.
5. **Historial:** filtros Todos / Contiene / Trazas / No detectado, agrupado por día, con el nombre del producto y el idioma.
6. **Ajustes:** perfil activo, banner Pro, idioma de la app, idiomas sin conexión, privacidad, guardar historial, vibración y acerca de.
7. **Paywall:** gratis tiene 5 escaneos al día, 1 perfil y 30 días de historial. Pro tiene escaneos sin límite, hasta 6 perfiles e historial siempre. Pago único de USD 3.99.
8. **Estados:** sin permiso de cámara, no se pudo leer, límite diario alcanzado y sin escaneos.

Navegación inferior de 3 pestañas: Escanear, Historial, Ajustes. Los perfiles viven en Ajustes y en el onboarding.
