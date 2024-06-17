#!/bin/bash

# Asegúrate de que el script se detenga si hay algún error
set -e

# Definir las rutas de los directorios
SOURCE_DIR="$HOME/Escritorio/YouTubeDownloaderBPM"
DEST_DIR="$HOME/Escritorio/YouTubeDownloaderBPM-Binaries"
VENV_DIR="$HOME/Escritorio/YouTubeDownloaderBPM/myenv"

# Definir el nombre del archivo comprimido
ARCHIVE_NAME="YouTubeDownloaderBPM-Binaries.rar"

# Definir el repositorio de GitHub y otros datos necesarios para la release
GITHUB_REPO="Juanan242/YTVideoToMP3AndBPMAnalyzer"
RELEASE_TAG="v1.0.0"

# Verificar que el token de GitHub esté definido
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN no está definido. Por favor, define el token de GitHub como una variable de entorno."
  exit 1
fi

# Activar el entorno virtual
source "$VENV_DIR/Scripts/activate"

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

# Eliminar los directorios y archivos generados en el directorio raíz del proyecto
rm -rf dist
rm -rf build
rm -f *.spec

echo "Archivos movidos a $DEST_DIR y directorios eliminados del directorio raíz"

# Desactivar el entorno virtual
deactivate

# Comprimir el directorio en un archivo .rar
if ! command -v rar &> /dev/null
then
    echo "RAR no está instalado. Instalándolo ahora..."
    sudo apt-get update
    sudo apt-get install rar
fi

rar a "$DEST_DIR/$ARCHIVE_NAME" "$DEST_DIR"

echo "Directorio $DEST_DIR comprimido en $ARCHIVE_NAME"

# Obtener la ID de la release existente
release_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPO/releases/tags/$RELEASE_TAG \
  | jq '.id')

# Obtener la ID del asset existente
asset_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPO/releases/$release_id/assets \
  | jq '.[] | select(.name=="'$ARCHIVE_NAME'") | .id')

# Eliminar el asset existente si hay uno
if [ ! -z "$asset_id" ]; then
  curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_REPO/releases/assets/$asset_id
  echo "Asset existente eliminado"
fi

# Subir el nuevo archivo .rar
upload_url=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPO/releases/$release_id \
  | jq -r '.upload_url' | sed -e "s/{?name,label}//")

curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @"$DEST_DIR/$ARCHIVE_NAME" \
  "$upload_url?name=$ARCHIVE_NAME"

echo "Release actualizada y $ARCHIVE_NAME subido a GitHub"
