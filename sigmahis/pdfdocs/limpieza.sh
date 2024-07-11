#!/bin/bash

# Función recursiva para borrar archivos en una carpeta
function borrar_archivos() {
  local carpeta="$1"
  echo "Borrando archivos en la carpeta: $carpeta"
  
  # Cambiar al directorio de la carpeta actual
  cd "$carpeta"

  # Borrar archivos con las extensiones .jpg, .png y .pdf
  find . -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.pdf" \) -delete

  # Recorrer las subcarpetas y llamar a la función recursivamente
  for subcarpeta in */; do
    borrar_archivos "$subcarpeta"
  done

  # Regresar al directorio anterior
  cd ..
}

# Llamar a la función con la ruta actual
borrar_archivos "$(pwd)"
