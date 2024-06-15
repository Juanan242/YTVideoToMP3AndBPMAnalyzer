#!/bin/bash

# Cambiar al directorio del proyecto
cd $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM/

# Generar el ejecutable utilizando PyInstaller y Wine
wine pyinstaller --onefile main.py

# Mover el ejecutable generado al directorio de binarios
mv dist/main.exe $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/
