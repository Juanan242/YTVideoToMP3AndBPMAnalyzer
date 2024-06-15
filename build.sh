#!/bin/bash

# Asegurarse de estar en el directorio del proyecto
cd $GITHUB_WORKSPACE

# Verificar si pyinstaller está disponible
if ! command -v pyinstaller &> /dev/null; then
    echo "pyinstaller no está instalado. Instalando pyinstaller..."
    pip3 install pyinstaller
fi

# Generar el ejecutable utilizando PyInstaller
pyinstaller --onefile Escritorio/YouTubeDownloaderBPM/main.py

# Verificar si se generó correctamente main.exe
if [ ! -f Escritorio/YouTubeDownloaderBPM/dist/main ]; then
    echo "Error: No se pudo encontrar el archivo main en la ubicación esperada."
    exit 1
fi

# Crear el directorio de binarios si no existe
mkdir -p $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/

# Mover el ejecutable generado al directorio de binarios
mv Escritorio/YouTubeDownloaderBPM/dist/main $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/main.exe
