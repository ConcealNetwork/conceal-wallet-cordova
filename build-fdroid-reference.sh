#!/bin/bash
# Build a reference APK the same way F-Droid does (prebuild + gradle + postbuild).
# Sign separately with apksigner after this script finishes.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT/platforms/android/app"
GRADLEW="$ROOT/platforms/android/gradlew"
TOOLS="${REPRODUCIBLE_APK_TOOLS:-$ROOT/.cache/reproducible-apk-tools}"

VERSION="$(grep -o 'version="[^"]*"' "$ROOT/config.xml" | head -1 | cut -d'"' -f2)"
JAVA_VERSION="$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)"
OUTPUT_DIR="$ROOT/builds"
OUTPUT_APK="$OUTPUT_DIR/Conceal_Mobile-v${VERSION}-java${JAVA_VERSION}.apk"

echo "F-Droid reference build"
echo "  version: $VERSION"
echo "  java:    $JAVA_VERSION"
echo ""

if [ ! -x "$GRADLEW" ]; then
    echo "Missing gradlew at $GRADLEW"
    exit 1
fi

if [ ! -d "$ROOT/www" ]; then
    echo "Missing exported www/ at $ROOT/www"
    exit 1
fi

echo "Sync www/ into Cordova assets (F-Droid prebuild)..."
rm -rf "$APP_DIR/src/main/assets/www"
cp -a "$ROOT/www" "$APP_DIR/src/main/assets/"

echo "Apply F-Droid Gradle tweaks..."
sed -i -e '/addSigningProps(cdv/d' "$APP_DIR/build.gradle"
cp "$ROOT/build-extras.gradle" "$APP_DIR/build-extras.gradle"

echo "Gradle assembleRelease (unsigned)..."
(
    cd "$APP_DIR"
    "$GRADLEW" clean assembleRelease
)

UNSIGNED=""
for candidate in \
    "$APP_DIR/build/outputs/apk/release/app-release-unsigned.apk" \
    "$APP_DIR/build/outputs/apk/release/app-release.apk"
do
    if [ -f "$candidate" ]; then
        UNSIGNED="$candidate"
        break
    fi
done

if [ -z "$UNSIGNED" ]; then
    echo "Release APK not found under $APP_DIR/build/outputs/apk/release/"
    find "$APP_DIR/build/outputs/apk" -name '*.apk' -type f || true
    exit 1
fi

if [ ! -f "$TOOLS/inplace-fix.py" ]; then
    echo "Fetching reproducible-apk-tools v0.3.0..."
    mkdir -p "$(dirname "$TOOLS")"
    rm -rf "$TOOLS"
    git clone --depth 1 --branch v0.3.0 https://github.com/obfusk/reproducible-apk-tools.git "$TOOLS"
fi

mkdir -p "$OUTPUT_DIR"
cp "$UNSIGNED" "$OUTPUT_APK"

echo "postbuild: inplace-fix.py --zipalign fix-newlines..."
"$TOOLS/inplace-fix.py" --zipalign fix-newlines "$OUTPUT_APK" \
    'assets/www/*.html' 'assets/www/*/*.html' 'assets/www/*/*/*.html' 'assets/www/*/*/*/*.html' \
    'assets/www/*.txt' 'assets/www/*/*.txt' 'assets/www/*/*/*.txt' 'assets/www/*/*/*/*.txt' \
    'assets/www/manifest.webmanifest' \
    'assets/www/_next/static/chunks/*.js' 'assets/www/_next/static/chunks/*.css' \
    'assets/www/_next/static/*/*.js' 'assets/www/_next/static/*/*.json' \
    'assets/www/_next/static/media/*.svg' 'assets/www/brand/*.svg' \
    'assets/www/plugins/*/*.js'

sha256sum "$OUTPUT_APK" | cut -d' ' -f1 > "$OUTPUT_APK.sha256"

echo ""
echo "Unsigned reference APK ready for signing:"
echo "  $OUTPUT_APK"
echo "  SHA256: $(cat "$OUTPUT_APK.sha256")"
