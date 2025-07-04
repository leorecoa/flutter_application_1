#!/bin/bash
set -e

echo "🚀 Starting Flutter Web build process..."

# Install dependencies
echo "📦 Installing system dependencies..."
yum update -y
yum install -y curl unzip xz git

# Download and extract Flutter
echo "⬇️ Downloading Flutter SDK..."
if [ ! -d "flutter" ]; then
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.9-stable.tar.xz -o flutter.tar.xz
    tar -xf flutter.tar.xz
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