@echo off
echo 🚀 AgendaFacil - Build APK Script
echo ================================

echo 📦 Limpando cache...
flutter clean

echo 📥 Instalando dependencias...
flutter pub get

echo 🔧 Analisando codigo...
flutter analyze --no-fatal-infos

echo 🏗️ Gerando APK Debug...
flutter build apk --debug

echo 🏗️ Gerando APK Release...
flutter build apk --release

echo ✅ Build concluido!
echo 📱 APKs gerados em:
echo    - Debug: build\app\outputs\flutter-apk\app-debug.apk
echo    - Release: build\app\outputs\flutter-apk\app-release.apk

echo 📋 Para instalar no celular:
echo    1. Ative "Fontes desconhecidas" no Android
echo    2. Transfira o APK via USB, WhatsApp ou Google Drive
echo    3. Toque no arquivo APK para instalar

pause