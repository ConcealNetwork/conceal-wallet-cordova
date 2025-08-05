# Conceal Wallet Cordova

THE SIMPLEST WAY TO USE CONCEAL – ANYWHERE AND ANY TIME

## Install

Install Cordova `npm install -g cordova`

Add required platforms `cordova platform add android@latest`

## Configure

Configure Platform:

- **Android** https://cordova.apache.org/docs/en/11.x/guide/platforms/android/index.html

## Development

Run android with target `cordova run android --target=API_35`

## Build Testing

Run `cordova build android --prod`

## Build Release

## Building the APK
a signign key will be required paired with build.json
### Generate the key:
```
keytool -genkey -v -keystore keys/release-keystore.jks -alias conceal-mobile -keyalg RSA -keysize 2048 -validity 10000 -storetype PKCS12
```
### Create the build.json file
```
{
	"android": {
        "release": {
            "keystore": "keys/release-keystore.jks",
			"storePassword": "<password>",
            "alias": "conceal-mobile",
            "password": <password>",
			"keystoreType": "PKCS12",
			"packageType": "apk"
		}
	}
}
```


### Method 1: Standard Build
```bash
cordova build android --prod --release
```

### Method 2: Build with Custom Version Naming (Recommended)

**Linux/Mac:**
```bash
./build-with-version.sh
```

**Windows:**
```bash
build-with-version.bat
```bash

This will create a file like: `Conceal_Mobile-v4.0.5.apk`
