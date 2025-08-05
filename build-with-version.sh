#!/bin/bash

# Build script for Conceal Wallet with custom version naming

# Get version from config.xml
VERSION=$(grep -o 'version="[^"]*"' config.xml | cut -d'"' -f2)

# Check if JAVA_HOME is set (from switch.sh)
if [ -n "$JAVA_HOME" ]; then
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using JAVA_HOME: $JAVA_HOME"
else
    echo "⚠️  JAVA_HOME not set, using system Java"
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
echo "Detected Java version: $JAVA_VERSION"

echo "🚀 Building Conceal Wallet APK"
echo "=============================="
echo "Version: $VERSION"
echo "Java Version: $JAVA_VERSION"
echo ""

# Build the APK
echo "📱 Building Android APK..."
cordova build android --prod --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Define output directory
    OUTPUT_DIR="builds"
    mkdir -p $OUTPUT_DIR
    
    # Define custom filename
    CUSTOM_FILENAME="Conceal_Mobile-v${VERSION}-java${JAVA_VERSION}.apk"
    
    # Copy and rename the APK
    SOURCE_APK="platforms/android/app/build/outputs/apk/release/app-release.apk"
    
    if [ -f "$SOURCE_APK" ]; then
        cp "$SOURCE_APK" "$OUTPUT_DIR/$CUSTOM_FILENAME"
        echo "📦 APK saved as: $OUTPUT_DIR/$CUSTOM_FILENAME"
        echo "📏 File size: $(du -h "$OUTPUT_DIR/$CUSTOM_FILENAME" | cut -f1)"
        echo "🔐 SHA256: $(sha256sum "$OUTPUT_DIR/$CUSTOM_FILENAME" | cut -d' ' -f1)"
        echo "$(sha256sum "$OUTPUT_DIR/$CUSTOM_FILENAME" | cut -d' ' -f1)" > "$OUTPUT_DIR/$CUSTOM_FILENAME.sha256"
        
    else
        echo "❌ APK file not found at expected location: $SOURCE_APK"
        echo "🔍 Looking for APK files..."
        find platforms/android/app/build/outputs/apk/release/ -name "*.apk" -type f
    fi
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🎉 Build completed successfully!" 