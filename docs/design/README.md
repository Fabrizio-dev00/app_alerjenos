# SanoScan: diseño

- **Guía oficial:** [DISENO_SANOSCAN.md](DISENO_SANOSCAN.md). Manda en lo visual; el plan del proyecto manda en la arquitectura.
- **Pantallas de referencia (versión final, v3):** carpeta `v3/`.
- La carpeta `mockups/` tiene la primera versión del diseño y queda solo como historial.

## Decisiones tomadas al implementar

- **Fuente:** la del sistema (Roboto en Android), como indica la guía.
- **Alérgenos del perfil:** 14 opciones. A las 12 del diseño se suman Lactosa y Tarwi (altramuz). "Mariscos" marca crustáceos y moluscos juntos.
- **Nombre del maní:** en español se muestra "Maní". La voz entiende también cacahuate y cacahuete.
- **Voz:** reconocimiento en el teléfono (`onDevice`). Si el teléfono no lo soporta sin conexión, la app lo dice y ofrece escribir o elegir a mano, sin pasar a la nube.
- **Regla de calidad:** "No detectado" solo aparece si se encontró la lista de ingredientes. Si no, se muestra "No pudimos leer la etiqueta" y no se descuenta el escaneo.
- **Historial gratis:** 30 días, con borrado automático. Pro lo guarda siempre (la guía pide confirmar esta fila).
