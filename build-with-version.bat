@echo off
setlocal enabledelayedexpansion

echo 🚀 Building Conceal Wallet APK
echo ==============================

REM Get version from config.xml
for /f "tokens=2 delims=<>" %%a in ('findstr "version=" config.xml') do set VERSION=%%a

echo Version: %VERSION%
echo.

echo 📱 Building Android APK...
cordova build android --prod --release

if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    
    REM Create output directory
    if not exist "builds" mkdir builds
    
    REM Define custom filename
    set CUSTOM_FILENAME=Conceal_Mobile-v%VERSION%.apk
    
    REM Copy and rename the APK
    set SOURCE_APK=platforms\android\app\build\outputs\apk\release\app-release.apk
    
    if exist "%SOURCE_APK%" (
        copy "%SOURCE_APK%" "builds\%CUSTOM_FILENAME%"
        echo 📦 APK saved as: builds\%CUSTOM_FILENAME%
        
        REM Get file size
        for %%A in ("builds\%CUSTOM_FILENAME%") do echo 📏 File size: %%~zA bytes
        
        REM Generate SHA256 (using PowerShell)
        echo 🔐 SHA256: 
        powershell -Command "Get-FileHash -Algorithm SHA256 'builds\%CUSTOM_FILENAME%' | Select-Object -ExpandProperty Hash"
        
        REM Save SHA256 to file
        powershell -Command "Get-FileHash -Algorithm SHA256 'builds\%CUSTOM_FILENAME%' | Select-Object -ExpandProperty Hash" > "builds\%CUSTOM_FILENAME%.sha256"
        echo ✅ SHA256 saved to: builds\%CUSTOM_FILENAME%.sha256
        
    ) else (
        echo ❌ APK file not found at expected location: %SOURCE_APK%
        echo 🔍 Looking for APK files...
        dir /s /b platforms\android\app\build\outputs\apk\release\*.apk
    )
) else (
    echo ❌ Build failed!
    exit /b 1
)

echo.
echo 🎉 Build completed successfully!
pause 