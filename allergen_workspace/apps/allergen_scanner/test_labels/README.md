# Etiquetas reales de prueba

Conjunto de fotos de etiquetas que se usa para medir el OCR y, desde la Semana 2, para comprobar que no hay falsos negativos. La meta es llegar a 25 o 30 etiquetas en español, inglés, francés, alemán, italiano y portugués.

## Cómo agregar una etiqueta

1. Toma la foto de la lista de ingredientes con la cámara normal del celular.
2. Copia la foto a `images/` con un nombre corto y sin espacios, por ejemplo `oreo_en.jpg`.
3. Agrega una entrada en `labels.json`:

```json
{
  "file": "oreo_en.jpg",
  "language": "en",
  "mustFind": ["ingredients", "wheat flour", "soy lecithin", "may contain milk"]
}
```

En `mustFind` van las palabras que **deben** leerse en la etiqueta: el encabezado de ingredientes, los alérgenos y las frases de trazas, tal como aparecen impresos.

Incluye también casos difíciles: fotos con reflejos, poca luz, letra muy chica o paquetes arrugados. Son los que más enseñan.

## Cómo correr el banco

Con el celular conectado por USB y desbloqueado, desde `allergen_workspace/apps/allergen_scanner`:

```powershell
./tool/run_label_benchmark.ps1
```

El script sube las fotos al celular, lee cada etiqueta con la foto normal y con contraste mejorado, y deja el resultado en `test_labels/report.json`.
