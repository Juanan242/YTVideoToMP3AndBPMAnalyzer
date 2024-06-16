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

# Eliminar los directorios y archivos generados en el directorio raíz del proyecto
rm -rf dist
rm -rf build
rm -f *.spec

echo "Archivos movidos a $DEST_DIR y directorios eliminados del directorio raíz"

# Desactivar el entorno virtual
deactivate

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
    git remote add origin https://github.com/Juanan242/YouTubeDownloaderBPM-Binaries-Linux.git
    echo "Repositorio remoto añadido"
fi

# Hacer push al repositorio remoto
git push -u origin main

echo "Cambios subidos al repositorio remoto"
