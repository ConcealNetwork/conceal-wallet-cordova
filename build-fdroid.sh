#!/bin/bash

# F-Droid build script for Conceal Mobile Wallet
# This script prepares the project for F-Droid builds

set -e

echo "Building Conceal Mobile Wallet for F-Droid..."

# Check if we're in the right directory
if [ ! -f "config.xml" ]; then
    echo "Error: config.xml not found. Please run this script from the project root."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

# Add Android platform if not present
if [ ! -d "platforms/android" ]; then
    echo "Adding Android platform..."
    npx cordova platform add android
fi

# Add plugins if not present
echo "Adding required plugins..."
npx cordova plugin add cordova-plugin-android-permissions
npx cordova plugin add cordova-plugin-camera
npx cordova plugin add cordova-plugin-insomnia
npx cordova plugin add cordova-plugin-app-version
npx cordova plugin add cordova-plugin-network-information

# Build for Android
echo "Building Android APK..."
npx cordova build android --release

# Copy the APK to the expected location for F-Droid
APK_PATH="platforms/android/app/build/outputs/apk/release/app-release.apk"
TARGET_PATH="conceal-mobile-5.0.0.apk"

if [ -f "$APK_PATH" ]; then
    echo "Copying APK to $TARGET_PATH..."
    cp "$APK_PATH" "$TARGET_PATH"
    echo "Build completed successfully!"
    echo "APK location: $TARGET_PATH"
else
    echo "Error: APK not found at $APK_PATH"
    echo "Available APK files:"
    ls -la platforms/android/app/build/outputs/apk/release/ || echo "No APK files found"
    exit 1
fi 