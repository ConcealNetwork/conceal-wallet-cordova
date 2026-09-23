# F-Droid Submission Guide for Conceal Mobile Wallet

Conceal Mobile is **live on F-Droid**. This document records how the Cordova shell is prepared for F-Droid builds and what maintainers/reviewers care about.

## Current release (this repo)

| Field | Value |
| --- | --- |
| Package name | `com.concealnetwork.concealmobile` |
| Version name | `6.0.5` |
| Version code | `56` |
| Config template | `configs/sdk35.xml` → `config.xml` via `./switch.sh` |
| Min / target / compile SDK | 24 / 35 / 36 |

Previous store build: **6.0.4** / versionCode **55**.

## Requirements checklist

### Completed

1. **fdroiddata metadata** — maintained in the [fdroiddata](https://gitlab.com/fdroid/fdroiddata) recipe (not edited from this change).
2. **Gradle / Cordova Android platform** — generated under `platforms/android` during build.
3. **Build scripts** — `build-fdroid.sh` / `build-fdroid.bat`.
4. **fastlane metadata** — `fastlane/metadata/android/en-US/` (changelogs keyed by versionCode).

### Screenshots

Still useful for store listing polish (`metadata/Screenshots/` placeholders may exist). Prefer real app UI, PNG, ≥320×320, no device frames.

## WASM provenance (closed F-Droid issue #17)

The committed `www/` tree includes WebAssembly binaries (e.g. under `www/_next/static/media/*.wasm`). They are **byte-for-byte copies** of `wasm-pack` output from [conceal-lib-js](https://github.com/ConcealNetwork/conceal-lib-js), not hand-edited blobs.

- F-Droid’s `scanignore` in fdroiddata whitelists these paths for the reproducible Cordova export.
- At runtime the wallet loads them over **`https://localhost`** (Cordova WebView) so streaming WebAssembly instantiation works.

No regeneration of `www/` is done in this repository’s F-Droid release workflow beyond committing the upstream Cordova export.

## Version management

- Bump **`version`** and **`android-versionCode`** in **both** `configs/sdk35.xml` and `configs/sdk30.xml` together (lockstep — same applicationId).
- Run `./switch.sh` to regenerate `config.xml` from the F-Droid (sdk35) template.
- Tag after human review (example: `v6.0.5-f-droid`).
- Auto-update on F-Droid follows git tags / version checks in fdroiddata.

## Build testing

```bash
./switch.sh   # choose sdk35 + F-Droid when prompted
# or
./build-fdroid.sh
```

## Support

- F-Droid docs: https://f-droid.org/docs/
- fdroiddata: https://gitlab.com/fdroid/fdroiddata
- Forum: https://forum.f-droid.org/

## License

MIT — compatible with F-Droid requirements.
