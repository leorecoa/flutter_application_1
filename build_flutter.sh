#!/bin/bash
set -e

echo "🚀 Starting Flutter Web build process..."

# Download and extract Flutter using available tools
echo "⬇️ Downloading Flutter SDK..."
if [ ! -d "flutter" ]; then
    # Use wget which is available in Amplify
    wget -O flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz
    
    # Extract using Python (available in Amplify)
    python3 -c "
import tarfile
import lzma
with lzma.open('flutter.tar.xz', 'rb') as xz_file:
    with tarfile.open(fileobj=xz_file, mode='r|') as tar:
        tar.extractall()
"
    rm flutter.tar.xz
fi

# Setup Flutter
export PATH="$PATH:`pwd`/flutter/bin"
echo "🔧 Configuring Flutter..."
flutter config --no-analytics
flutter doctor --android-licenses || true

# Install dependencies
echo "📚 Installing project dependencies..."
flutter pub get

# Build web
echo "🏗️ Building Flutter Web..."
flutter build web --release --base-href=/ --web-renderer canvaskit

echo "✅ Flutter Web build completed successfully!"