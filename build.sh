cd ~/Escritorio/YouTubeDownloaderBPM

# Generar el ejecutable utilizando PyInstaller y Wine
wine pyinstaller --onefile main.py

# Mover el ejecutable generado al directorio de binarios
mv dist/main.exe Escritorio/YouTubeDownloaderBPM-Binaries/

gh release upload v1 Escritorio/YouTubeDownloaderBPM-Binaries/main.exe
