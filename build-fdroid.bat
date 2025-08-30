@echo off
setlocal enabledelayedexpansion

REM Build script for Conceal Wallet with custom version naming and F-Droid tweaks

REM Get version from config.xml
for /f "tokens=2 delims=<>" %%a in ('findstr "version=" config.xml') do set VERSION=%%a

REM Check if JAVA_HOME is set (from switch.bat)
if defined JAVA_HOME (
    set PATH=%JAVA_HOME%\bin;%PATH%
    echo Using JAVA_HOME: %JAVA_HOME%
) else (
    echo ⚠️  JAVA_HOME not set, using system Java
)

REM Get Java version
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr "version"') do set JAVA_VERSION=%%i
set JAVA_VERSION=!JAVA_VERSION:"=!

echo 🚀 Building Conceal Wallet APK
echo ==============================
echo Version: %VERSION%
echo Java Version: %JAVA_VERSION%
echo.

REM Tweak for f-droid
REM The dependenciesInfo block is now automatically injected via Cordova hooks
REM See hooks/before_build.js and build-extras.gradle

REM Build the APK
echo 📱 Building Android APK...
npx cordova build android --release -- --packageType=apk

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    
    REM Define output directory
    set OUTPUT_DIR=builds
    if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
    
    REM Define custom filename
    set CUSTOM_FILENAME=Conceal_Mobile-v%VERSION%-java%JAVA_VERSION%.apk
    
    REM Copy and rename the APK
    set SOURCE_APK=platforms\android\app\build\outputs\apk\release\app-release.apk
    
    if exist "%SOURCE_APK%" (
        copy "%SOURCE_APK%" "%OUTPUT_DIR%\%CUSTOM_FILENAME%"
        echo 📦 APK saved as: %OUTPUT_DIR%\%CUSTOM_FILENAME%
        
        REM Get file size
        for %%A in ("%OUTPUT_DIR%\%CUSTOM_FILENAME%") do echo 📏 File size: %%~zA bytes
        
        REM Generate SHA256
        echo 🔐 SHA256: 
        powershell -Command "Get-FileHash -Algorithm SHA256 '%OUTPUT_DIR%\%CUSTOM_FILENAME%' | Select-Object -ExpandProperty Hash"
        
        REM Save SHA256 to file
        powershell -Command "Get-FileHash -Algorithm SHA256 '%OUTPUT_DIR%\%CUSTOM_FILENAME%' | Select-Object -ExpandProperty Hash" > "%OUTPUT_DIR%\%CUSTOM_FILENAME%.sha256"
        echo ✅ SHA256 saved to: %OUTPUT_DIR%\%CUSTOM_FILENAME%.sha256
        
    ) else (
        echo ❌ APK file not found at expected location: %SOURCE_APK%
        echo 🔍 Looking for APK files...
        dir /s /b platforms\android\app\build\outputs\apk\release\*.apk 2>nul || echo No APK files found
    )
) else (
    echo ❌ Build failed!
    exit /b 1
)

echo.
echo 🎉 Build for F-Droid completed successfully!
pause 