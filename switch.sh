#!/bin/bash

echo
echo "Choose config:"
echo "1. sdk35.xml (modern) - using JAVA 21"
echo "2. sdk30.xml (old phones) - using JAVA 11"
echo
read -p "Enter 1 or 2: " choice

if [ "$choice" = "1" ]; then
    # Use Java 21 for modern builds
    export JAVA_HOME=/c/Program\ Files/Java/jdk-21
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using Java version:"
    java -version
    
    cp configs/sdk35.xml config.xml
    cp configs/package-sdk35.json package.json
    echo "Applied sdk35.xml + package-sdk35.json (modern)"
    echo "Cleaning and rebuilding..."
    cordova clean android
    rm -rf platforms/android
    rm -rf node_modules
    npm install
    cordova platform add android
elif [ "$choice" = "2" ]; then
    # Use Java 11 for legacy builds (Gradle 7.1.1 requirement)
    export JAVA_HOME=/c/Program\ Files/Java/jdk-11
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using Java version:"
    java -version
    
    cp configs/sdk30.xml config.xml
    cp configs/package-sdk30.json package.json
    echo "Applied sdk30.xml + package-sdk30.json (old phones)"
    echo "Cleaning and rebuilding..."
    cordova clean android
    rm -rf platforms/android
    rm -rf node_modules
    npm install
    cordova platform add android
else
    echo "Invalid choice"
fi
echo 