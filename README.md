# Apache Cordova

### Mobile apps with HTML, CSS &amp; JS Target multiple platforms with one code base

Install Cordova `npm install -g cordova`

Add required platforms `cordova platform add <platform name>`

Configure Each Platform:

- **Android** https://cordova.apache.org/docs/en/10.x/guide/platforms/android/index.html

- **iOS** https://cordova.apache.org/docs/en/10.x/guide/platforms/ios/index.html

- **Windows** https://cordova.apache.org/docs/en/10.x/guide/platforms/windows/index.html

- **OSx** https://cordova.apache.org/docs/en/10.x/guide/platforms/osx/index.html

- **Electron**  https://cordova.apache.org/docs/en/10.x/guide/platforms/electron/index.html

Build Angular application into Cordova
`ng build --configuration production --base-href . --output-path ..\cordova\www\`

Run your app `cordova run <platform name>`
