# Configuration Files

This folder contains different `config.xml` and `package.json` configurations for building the Conceal Mobile app with different Android SDK versions and settings.

`config.xml` at the repo root is generated — edit the templates here, then run `./switch.sh` (repo root) to apply.

## Version lockstep (same applicationId)

Both `sdk35.xml` / `sdk30.xml` and `package-sdk35.json` / `package-sdk30.json` share package id `com.concealnetwork.concealmobile`. Keep widget **`version`** / **`android-versionCode`** and npm **`version`** identical across both SDK tracks for every release so switching configs cannot produce a Play/F-Droid version collision.

Current release identity: **6.0.5** / versionCode **56** (npm `version` **6.0.5** in both package templates).

Do **not** set `android-maxSdkVersion` (it hard-blocks newer OS installs; target/compile SDK already define the build).

## Available Configurations

### `sdk35.xml` + `package-sdk35.json` - Modern Devices (Default / F-Droid)
- **Target SDK**: 35
- **Compile SDK**: 36
- **Build Tools**: 36.0.0
- **Min SDK**: 24 (Android 7.0+)
- **Best for**: F-Droid and modern devices

### `sdk30.xml` + `package-sdk30.json` - Legacy Support
- **Target SDK**: 30 (Android 11)
- **Compile SDK**: 30
- **Build Tools**: 30.0.3
- **Min SDK**: 24 (Android 7.0+)
- **Best for**: Older phones capped at Android 11 tooling

## How to Use

From the repo root:

```bash
./switch.sh
```

Choose `1` for sdk35 or `2` for sdk30, then `f` for F-Droid or `r` for regular.

### Manual Method
1. Backup: `cp config.xml config.xml.backup`
2. Apply: `cp configs/sdk35.xml config.xml` (or `sdk30.xml`)
3. Build as usual

## Configuration Details

### SDK 35 (Modern)
```xml
<preference name="android-targetSdkVersion" value="35" />
<preference name="android-compileSdkVersion" value="36" />
<preference name="android-buildToolsVersion" value="36.0.0" />
<preference name="android-minSdkVersion" value="24" />
```

### SDK 30 (Legacy)
```xml
<preference name="android-targetSdkVersion" value="30" />
<preference name="android-compileSdkVersion" value="30" />
<preference name="android-buildToolsVersion" value="30.0.3" />
<preference name="android-minSdkVersion" value="24" />
```
