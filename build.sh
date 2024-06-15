#!/bin/bash

# Cambiar al directorio del proyecto
cd $GITHUB_WORKSPACE

# Generar el ejecutable utilizando PyInstaller y Wine
wine pyinstaller --onefile Escritorio/YouTubeDownloaderBPM/main.py

# Mover el ejecutable generado al directorio de binarios
mv Escritorio/YouTubeDownloaderBPM/dist/main.exe $GITHUB_WORKSPACE/Escritorio/YouTubeDownloaderBPM-Binaries/
