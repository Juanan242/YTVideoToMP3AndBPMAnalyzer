#!/bin/bash

# Asegúrate de que el script se detenga si hay algún error
set -e

# Definir las rutas de los directorios
SOURCE_DIR="$HOME/Escritorio/YouTubeDownloaderBPM"
DEST_DIR="$HOME/Escritorio/YouTubeDownloaderBPM-Binaries-prueba"
VENV_DIR="$HOME/Escritorio/YouTubeDownloaderBPM/myenv"

# Activar el entorno virtual
source "$VENV_DIR/bin/activate"

# Verificar si pyinstaller está instalado, si no, instalarlo
if ! command -v pyinstaller &> /dev/null
then
    echo "PyInstaller no está instalado. Instalándolo ahora..."
    pip install pyinstaller
else
    echo "PyInstaller ya está instalado."
fi

# Ejecutar PyInstaller para crear el ejecutable
pyinstaller --onefile -w main.py

# Crear el directorio de destino si no existe
mkdir -p "$DEST_DIR/dist"
mkdir -p "$DEST_DIR/build"
mkdir -p "$DEST_DIR/spec"

# Mover los archivos generados al directorio de destino
mv dist/* "$DEST_DIR/dist/"
mv build/* "$DEST_DIR/build/"
mv *.spec "$DEST_DIR/spec/"

echo "Archivos movidos a $DEST_DIR"

# Eliminar los archivos generados en el directorio raíz
rm -rf dist
rm -rf build
rm -f *.spec

echo "Archivos movidos a $DEST_DIR y directorios eliminados del directorio raíz"

# Desactivar el entorno virtual
deactivate
