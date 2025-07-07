#!/bin/bash

# AGENDEMAIS Production Build Script
# This script builds the app with all production optimizations

set -e

echo "🚀 Building AGENDEMAIS for Production..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔨 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code for issues
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos --no-fatal-warnings

# Run tests (skip if no tests exist)
if [ -d "test" ]; then
    echo "🧪 Running tests..."
    flutter test
else
    echo "⚠️ No tests found, skipping test phase"
fi

# Build for web with production optimizations
echo "🌐 Building for web with production optimizations..."
flutter build web \
    --release \
    --tree-shake-icons \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
    --web-renderer canvaskit \
    --pwa-strategy offline-first \
    --base-href="/" \
    --source-maps

# Copy production assets
echo "📋 Copying production assets..."
cp web/.htaccess build/web/
cp web/app.yaml build/web/

# Update service worker cache version
echo "🔄 Updating service worker cache version..."
sed -i.bak "s/agendemais-production-v[0-9]\+\.[0-9]\+/agendemais-production-v$(date +%Y%m%d-%H%M%S)/" build/web/sw.js
rm -f build/web/sw.js.bak

# Generate build info
echo "📝 Generating build info..."
cat > build/web/build-info.json << EOF
{
  "buildTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "1.0.0",
  "environment": "production",
  "gitCommit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
  "buildNumber": "$(date +%Y%m%d%H%M%S)"
}
EOF

# Create deployment package
echo "📦 Creating deployment package..."
cd build/web
tar -czf "../agendemais-web-production-$(date +%Y%m%d-%H%M%S).tar.gz" .
cd ../../

# Verify build
echo "✅ Verifying build..."
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Build failed: index.html not found"
    exit 1
fi

if [ ! -f "build/web/main.dart.js" ]; then
    echo "❌ Build failed: main.dart.js not found"
    exit 1
fi

# Check bundle size
BUNDLE_SIZE=$(du -sh build/web/main.dart.js | cut -f1)
echo "📏 Bundle size: $BUNDLE_SIZE"

# Security check - ensure no sensitive data in build
echo "🔒 Running security checks..."
if grep -r "mock\|test\|debug" build/web/ --exclude="*.map" --exclude="build-info.json" &> /dev/null; then
    echo "⚠️  Warning: Found test/mock/debug references in production build"
fi

echo ""
echo "🎉 Production build completed successfully!"
echo ""
echo "📊 Build Summary:"
echo "   • Output directory: build/web/"
echo "   • Bundle size: $BUNDLE_SIZE"
echo "   • Package: build/agendemais-web-production-$(date +%Y%m%d-%H%M%S).tar.gz"
echo ""
echo "🚀 Deployment Instructions:"
echo "   1. Upload contents of build/web/ to your web server"
echo "   2. Ensure .htaccess rules are applied"
echo "   3. Configure SSL certificate"
echo "   4. Set up proper CORS headers"
echo "   5. Test PWA installation"
echo ""
echo "🔧 Environment Variables Required:"
echo "   • AWS_API_ENDPOINT"
echo "   • AWS_REGION"
echo "   • COGNITO_USER_POOL_ID"
echo "   • COGNITO_APP_CLIENT_ID"
echo "   • COGNITO_IDENTITY_POOL_ID"
echo "   • S3_BUCKET_NAME"
echo ""
echo "✅ Ready for production deployment!"