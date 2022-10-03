# Conceal Wallet Cordova

THE SIMPLEST WAY TO USE CONCEAL – ANYWHERE AND ANY TIME

## Install

Install Cordova `npm install -g cordova`

Add required platforms `cordova platform add android@latest`

## Configure

Configure Each Platform:

- **Android** https://cordova.apache.org/docs/en/11.x/guide/platforms/android/index.html

- **iOS** https://cordova.apache.org/docs/en/11.x/guide/platforms/ios/index.html

- **Windows** https://cordova.apache.org/docs/en/11.x/guide/platforms/windows/index.html

- **OSx** https://cordova.apache.org/docs/en/11.x/guide/platforms/osx/index.html

- **Electron**  https://cordova.apache.org/docs/en/11.x/guide/platforms/electron/index.html

## Development

Run `cordova run <platform name>`

Run android with target `cordova run android --target=API_32`

## Build Testing

Run `cordova build android --prod`

## Build Release

Run `cordova build android --prod --release`

##### Plugins

- Fix for osx build on apple silicon `cordova platform add https://github.com/bpresles/cordova-osx.git#AppleSilicon`

- Fix for file access on iOS `cordova plugin add @globules-io/cordova-plugin-ios-xhr`

- Plugin for NavigationBar `cordova plugin add https://github.com/ollm/cordova-plugin-navigationbar.git`

- Plugin for StatusBar `cordova plugin add cordova-plugin-statusbar`