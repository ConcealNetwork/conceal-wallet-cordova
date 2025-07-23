@echo off
echo.
echo Choose config:
echo 1. sdk35.xml (modern) - using JAVA 21
echo 2. sdk30.xml (old phones) - using JAVA 11
echo.
set /p choice="Enter 1 or 2: "

if "%choice%"=="1" (
    REM Use Java 21 for modern builds
    set JAVA_HOME=C:\Program Files\Java\jdk-21
    set PATH=%JAVA_HOME%\bin;%PATH%
    echo Using Java version:
    java -version
    
    copy configs\sdk35.xml config.xml
    copy configs\package-sdk35.json package.json
    echo Applied sdk35.xml + package-sdk35.json (modern)
    echo Cleaning and rebuilding...
    call cordova clean android
    if exist platforms\android rmdir /s /q platforms\android
    if exist node_modules rmdir /s /q node_modules
    call npm install
    call cordova platform add android
    call cordova build android --release
) else if "%choice%"=="2" (
    REM Use Java 11 for legacy builds (Gradle 7.1.1 requirement)
    set JAVA_HOME=C:\Program Files\Java\jdk-11
    set PATH=%JAVA_HOME%\bin;%PATH%
    echo Using Java version:
    java -version
    
    copy configs\sdk30.xml config.xml
    copy configs\package-sdk30.json package.json
    echo Applied sdk30.xml + package-sdk30.json (old phones)
    echo Cleaning and rebuilding...
    call cordova clean android
    if exist platforms\android rmdir /s /q platforms\android
    if exist node_modules rmdir /s /q node_modules
    call npm install
    call cordova platform add android
    call cordova build android --release
) else (
    echo Invalid choice
)
echo.
pause 