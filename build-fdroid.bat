@echo off
REM F-Droid build script for Conceal Mobile Wallet (Windows)
REM This script prepares the project for F-Droid builds

echo Building Conceal Mobile Wallet for F-Droid...

REM Check if we're in the right directory
if not exist "config.xml" (
    echo Error: config.xml not found. Please run this script from the project root.
    exit /b 1
)

REM Install dependencies if needed
if not exist "node_modules" (
    echo Installing npm dependencies...
    npm install
)

REM Add Android platform if not present
if not exist "platforms\android" (
    echo Adding Android platform...
    npx cordova platform add android
)

REM Add plugins if not present
echo Adding required plugins...
npx cordova plugin add cordova-plugin-android-permissions
npx cordova plugin add cordova-plugin-camera
npx cordova plugin add cordova-plugin-insomnia
npx cordova plugin add cordova-plugin-app-version
npx cordova plugin add cordova-plugin-network-information

REM Build for Android
echo Building Android APK...
npx cordova build android --release

REM Copy the APK to the expected location for F-Droid
set APK_PATH=platforms\android\app\build\outputs\apk\release\app-release.apk
set TARGET_PATH=conceal-mobile-5.0.0.apk

if exist "%APK_PATH%" (
    echo Copying APK to %TARGET_PATH%...
    copy "%APK_PATH%" "%TARGET_PATH%"
    echo Build completed successfully!
    echo APK location: %TARGET_PATH%
) else (
    echo Error: APK not found at %APK_PATH%
    echo Available APK files:
    dir platforms\android\app\build\outputs\apk\release\ 2>nul || echo No APK files found
    exit /b 1
) 