#!/bin/bash
set -e

echo "🚀 Building Flutter Web..."
flutter pub get
flutter build web --release

echo "📁 Copying build to root..."
cp -r build/web/* .

echo "✅ Build completed and copied!"
ls -la *.html *.js