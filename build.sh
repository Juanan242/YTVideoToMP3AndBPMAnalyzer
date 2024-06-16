#!/bin/bash

# Asegúrate de que el script se detenga si hay algún error
set -e

# Definir las rutas de los directorios
SOURCE_DIR="$HOME/Escritorio/YouTubeDownloaderBPM"
DEST_DIR="$HOME/Escritorio/YouTubeDownloaderBPM-Binaries-prueba"

# Ejecuta PyInstaller para crear el ejecutable
pyinstaller --onefile -w main.py

# Crear el directorio de destino si no existe
mkdir -p "$DEST_DIR"

# Mover los archivos generados al directorio de destino
mv dist/* "$DEST_DIR/"
mv build/* "$DEST_DIR/"
mv *.spec "$DEST_DIR/"

echo "Archivos movidos a $DEST_DIR"
