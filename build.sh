#!/bin/bash

# Asegúrate de que el script se detenga si hay algún error
set -e

# Definir las rutas de los directorios
SOURCE_DIR="$HOME/Escritorio/YouTubeDownloaderBPM"
DEST_DIR="$HOME/Escritorio/YouTubeDownloaderBPM-Binaries-prueba"
VENV_DIR="$HOME/Escritorio/YouTubeDownloaderBPM/myenv"

# Definir el nombre del archivo comprimido
ARCHIVE_NAME="YouTubeDownloaderBPM-Binaries-prueba.rar"

# Definir el token de GitHub y otros datos necesarios para la release
GITHUB_REPO="Juanan242/YTVideoToMP3AndBPMAnalyzer"
GITHUB_TOKEN="YOUR_GITHUB_TOKEN"
RELEASE_NAME="New Release"
RELEASE_TAG="v1.0.0"

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

# Cambiar al directorio de destino
cd "$DEST_DIR"

# Inicializar git si no está inicializado
if [ ! -d .git ]; then
    git init
    echo "Repositorio Git inicializado en $DEST_DIR"
fi

# Configurar Git LFS y trackear archivos grandes si no se ha realizado previamente
if [ ! -f .gitattributes ]; then
    git lfs install
    git lfs track "*.pkg"
    git lfs track "dist/main"
    git lfs track "main"
    git add .gitattributes
    echo "Git LFS configurado y archivos grandes trackeados"
fi

# Añadir los archivos al repositorio y hacer commit
git add .
git commit -m "Add large files with Git LFS"

# Verificar si la rama main no existe y crearla
if ! git show-ref --quiet refs/heads/main; then
    git branch -M main
    echo "Rama 'main' creada"
fi

# Añadir el repositorio remoto si no está configurado
if ! git remote | grep -q origin; then
    git remote add origin https://github.com/$GITHUB_REPO.git
    echo "Repositorio remoto añadido"
fi

# Hacer push al repositorio remoto
git push -u origin main

echo "Cambios subidos"

# Crear una nueva release en GitHub y subir el archivo .rar
response=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_REPO/releases \
  -d @- << EOF
{
  "tag_name": "$RELEASE_TAG",
  "target_commitish": "main",
  "name": "$RELEASE_NAME",
  "body": "Descripción de la release",
  "draft": false,
  "prerelease": false
}
EOF
)

upload_url=$(echo "$response" | grep -o '"upload_url": "[^"]*' | sed 's/"upload_url": "\(.*\){.*}/\1/')

curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/zip" \
  --data-binary @"$DEST_DIR/$ARCHIVE_NAME" \
  "$upload_url?name=$ARCHIVE_NAME"

echo "Release creada y $ARCHIVE_NAME subido a GitHub"
