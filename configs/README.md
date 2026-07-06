# Configuration Files

This folder contains different `config.xml` and `package.json` configurations for building the Conceal Mobile app with different Android SDK versions and settings.

## Available Configurations

### `sdk35.xml` + `package-sdk35.json` - Modern Devices (Default)
- **Target SDK**: 35 (Android 14)
- **Compile SDK**: 35
- **Build Tools**: 35.0.0
- **Cordova Android**: 14.0.1
- **Package Type**: Bundle (AAB)
- **Compatibility**: Android 5.1+ (API 22+)
- **Best for**: Modern devices, Google Play Store distribution
- **Features**: Latest Android features, optimized for newer devices

### `sdk30.xml` + `package-sdk30.json` - Legacy Support
- **Target SDK**: 30 (Android 11)
- **Compile SDK**: 30
- **Build Tools**: 30.0.3
- **Cordova Android**: 12.0.0
- **Package Type**: APK
- **Compatibility**: Android 5.1+ (API 22+)
- **Best for**: Older phones, devices with Android 11 or below
- **Features**: Better compatibility with older devices, APK format for easier distribution

## How to Use

### Interactive Script (Recommended)
Run the interactive script to choose your configuration:

**Windows:**
```bash
scripts\switch-config.bat
```

**Unix/Linux/Mac:**
```bash
chmod +x scripts/switch-config.sh
./scripts/switch-config.sh
```

### Manual Method
1. Backup your current config: `cp config.xml config.xml.backup`
2. Apply desired config: `cp configs/sdk30.xml config.xml`
3. Build: `cordova build android --release`
4. Restore if needed: `cp config.xml.backup config.xml`

## Configuration Details

### SDK 35 (Modern)
```xml
<preference name="android-targetSdkVersion" value="35" />
<preference name="android-compileSdkVersion" value="35" />
<preference name="android-buildToolsVersion" value="35.0.0" />
<preference name="android-maxSdkVersion" value="35" />
```

### SDK 30 (Legacy)
```xml
<preference name="android-targetSdkVersion" value="30" />
<preference name="android-compileSdkVersion" value="30" />
<preference name="android-buildToolsVersion" value="30.0.3" />
<preference name="android-maxSdkVersion" value="30" />
```

## Adding New Configurations

To add a new configuration:

1. Create a new XML file in this folder (e.g., `sdk28.xml`)
2. Copy an existing configuration and modify the SDK settings
3. Update this README with the new configuration details
4. The interactive script will automatically detect and list the new configuration

## Prerequisites

Make sure you have the required Android SDK versions installed:

```bash
# For SDK 35
sdkmanager "platforms;android-35"
sdkmanager "build-tools;35.0.0"

# For SDK 30
sdkmanager "platforms;android-30"
sdkmanager "build-tools;30.0.3"
```

## Safety Features

- **Automatic backup**: Current config is always backed up before switching
- **Validation**: Scripts validate input and check for required files
- **Clean builds**: Previous build artifacts are removed to prevent conflicts
- **Easy restore**: Simple command to restore previous configuration 