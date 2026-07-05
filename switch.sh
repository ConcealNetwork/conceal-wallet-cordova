#!/bin/bash

echo
echo "Choose config:"
echo "1. sdk35.xml (modern) - using Java 17+"
echo "2. sdk30.xml (old phones) - using JAVA 11"
echo
read -p "Enter 1 or 2: " choice

echo
echo "Choose type F-droid or regular(f/r)"
echo
read -p "Enter f or r: " type


if [[ "$choice" = "1" ]]; then
    # Modern builds: Java 17+ (Linux) or Java 21 (Windows)
    if [[ -z "$JAVA_HOME" || ! -x "$JAVA_HOME/bin/java" ]]; then
        if [[ -d /usr/lib/jvm/java-21-openjdk-amd64 ]]; then
            export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
        elif [[ -d /usr/lib/jvm/java-17-openjdk-amd64 ]]; then
            export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        else
            export JAVA_HOME=/c/Program\ Files/Java/jdk-21
        fi
    fi
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using Java version:"
    java -version
    
    cp configs/sdk35.xml config.xml
    cp configs/package-sdk35.json package.json
    echo "Applied sdk35.xml + package-sdk35.json (modern)"
    
    # Ensure the hook is in config.xml for F-Droid dependenciesInfo injection (BEFORE platform add)
    if [[ "$type" = "f" || "$type" = "F" ]]; then
        echo "🔧 Ensuring hook is in config.xml for F-Droid..."
        if ! grep -q '<hook src="hooks/before_build.js" type="before_build" />' config.xml; then
            echo "⚠️  Hook not found in config.xml, adding it..."
            # Add the hook after the opening widget tag
            sed -i '/<widget/a\    <hook src="hooks/before_build.js" type="before_build" />' config.xml
            echo "✅ Hook added to config.xml"
        else
            echo "✅ Hook already present in config.xml"
        fi
    fi
    
    echo "Cleaning and rebuilding..."
    cordova clean android
    rm -rf platforms/android
    rm -rf node_modules
    npm ci
    cordova platform add android
    
    echo ""
    echo "🚀 Starting build process..."
    if [[ "$type" = "f" || "$type" = "F" ]]; then
        ./build-fdroid.sh
    else
        ./build-with-version.sh
    fi
elif [[ "$choice" = "2" ]]; then
    # Legacy builds: Java 11 (Gradle 7.1.1 requirement)
    if [[ -z "$JAVA_HOME" || ! -x "$JAVA_HOME/bin/java" ]]; then
        if [[ -d /usr/lib/jvm/java-11-openjdk-amd64 ]]; then
            export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        else
            export JAVA_HOME=/c/Program\ Files/Java/jdk-11
        fi
    fi
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using Java version:"
    java -version
    
    cp configs/sdk30.xml config.xml
    cp configs/package-sdk30.json package.json
    echo "Applied sdk30.xml + package-sdk30.json (old phones)"
    
    # Ensure the hook is in config.xml for F-Droid dependenciesInfo injection (BEFORE platform add)
    if [[ "$type" = "f" || "$type" = "F" ]]; then
        echo "🔧 Ensuring hook is in config.xml for F-Droid..."
        if ! grep -q '<hook src="hooks/before_build.js" type="before_build" />' config.xml; then
            echo "⚠️  Hook not found in config.xml, adding it..."
            # Add the hook after the opening widget tag
            sed -i '/<widget/a\    <hook src="hooks/before_build.js" type="before_build" />' config.xml
            echo "✅ Hook added to config.xml"
        else
            echo "✅ Hook already present in config.xml"
        fi
    fi
    
    echo "Cleaning and rebuilding..."
    cordova clean android
    rm -rf platforms/android
    rm -rf node_modules
    rm -rf package-lock.json
    npm install
    cordova platform add android
    
    echo ""
    echo "🚀 Starting build process..."
    if [[ "$type" = "f" || "$type" = "F" ]]; then
        ./build-fdroid.sh
    else
        ./build-with-version.sh
    fi
else
    echo "Invalid choice"
fi
echo 