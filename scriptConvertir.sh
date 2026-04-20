#!/bin/bash

# Output directory
OUTPUT_DIR="converted_mp4"

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Convirtiendo videos a MP4..."

# Loop through common video formats
for file in *.{mp4,mkv,avi,mov,webm,flv,wmv}; do
  # Skip if no files match
  [ -e "$file" ] || continue

  filename=$(basename -- "$file")
  name="${filename%.*}"

  echo "Procesando: $file"

  ffmpeg -i "$file" \
    -c:v libx264 \
    -preset fast \
    -crf 23 \
    -c:a aac \
    -b:a 128k \
    "$OUTPUT_DIR/$name.mp4"

done

echo "✅ Conversión completada."

# Open folder depending on desktop environment
if command -v xdg-open > /dev/null; then
  xdg-open "$OUTPUT_DIR"
elif command -v nautilus > /dev/null; then
  nautilus "$OUTPUT_DIR"
elif command -v dolphin > /dev/null; then
  dolphin "$OUTPUT_DIR"
else
  echo "No se pudo abrir automáticamente la carpeta."
fi
