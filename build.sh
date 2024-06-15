#!/bin/bash

# Asegurarse de estar en el directorio del proyecto
cd $GITHUB_WORKSPACE/YouTubeDownloaderBPM

# Instalar Python y pip si no están disponibles
if ! command -v python3 &> /dev/null; then
    echo "Python3 no está instalado. Instalando Python3..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

# Verificar si pyinstaller está disponible
if ! command -v pyinstaller &> /dev/null; then
    echo "pyinstaller no está instalado. Instalando pyinstaller..."
    pip3 install pyinstaller
fi

# Verificar que el archivo main.py existe en la ubicación esperada
if [ ! -f main.py ]; then
    echo "Error: No se pudo encontrar el archivo main.py en la ubicación esperada."
    exit 1
fi

# Generar el ejecutable utilizando PyInstaller
pyinstaller --onefile -w main.py

# Verificar si se generó correctamente main.exe
if [ ! -f dist/main ]; then
    echo "Error: No se pudo encontrar el archivo main en la ubicación esperada."
    exit 1
fi

# Crear el directorio de binarios si no existe
mkdir -p $GITHUB_WORKSPACE/YouTubeDownloaderBPM-Binaries/

# Mover el ejecutable generado al directorio de binarios
mv dist/main $GITHUB_WORKSPACE/YouTubeDownloaderBPM-Binaries/
