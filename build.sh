#!/bin/bash

# Asegúrate de que el script se detenga si hay algún error
set -e

# Ejecuta PyInstaller para crear el ejecutable
pyinstaller --onefile -w main.py
