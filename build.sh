#!/bin/bash

# Asegurarse de estar en el directorio del proyecto
cd $GITHUB_WORKSPACE

# Verificar si wine está disponible
if ! command -v wine &> /dev/null; then
    echo "Error: wine no está instalado o no configurado correctamente."
    exit 1
fi

# Generar el ejecutable utilizando PyInstaller y Wine
wine pyinstaller --onefile Escritorio/YouTubeDownloaderBPM/main.py

# Verificar si se generó correctamente main.exe
if [ ! -f Escritorio/YouTubeDownloaderBPM/dist/main.exe ]; then
    echo "Error: No se pudo encontrar el archivo main.exe en la ubicación esperada."
    exit 1
fi

# Mover el ejecutable generado al directorio de binarios
mv Escritorio/YouTubeDownloaderBPM/dist/main.exe $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/
