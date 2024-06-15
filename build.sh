#!/bin/bash

# Asegurarse de estar en el directorio del proyecto
cd $GITHUB_WORKSPACE

# Verificar si wine está disponible
if ! command -v wine &> /dev/null; then
    echo "wine no está instalado. Instalando wine..."
    # Instalar wine si no está disponible
    if [ "$(uname -m)" = "x86_64" ]; then
        sudo dpkg --add-architecture i386
    fi
    sudo apt update
    sudo apt install -y wine64 wine32
    # Verificar si la instalación fue exitosa
    if ! command -v wine &> /dev/null; then
        echo "Error: No se pudo instalar wine correctamente."
        exit 1
    fi
fi

# Configurar wine para usar una implementación sin interfaz gráfica
export DISPLAY=:0

# Verificar si pyinstaller está disponible
if ! command -v pyinstaller &> /dev/null; then
    echo "pyinstaller no está instalado. Instalando pyinstaller..."
    pip3 install pyinstaller
fi

# Generar el ejecutable utilizando PyInstaller y Wine
wine pyinstaller --onefile Escritorio/YouTubeDownloaderBPM/main.py

# Verificar si se generó correctamente main.exe
if [ ! -f Escritorio/YouTubeDownloaderBPM/dist/main.exe ]; then
    echo "Error: No se pudo encontrar el archivo main.exe en la ubicación esperada."
    exit 1
fi

# Crear el directorio de binarios si no existe
mkdir -p $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/

# Mover el ejecutable generado al directorio de binarios
mv Escritorio/YouTubeDownloaderBPM/dist/main.exe $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/
