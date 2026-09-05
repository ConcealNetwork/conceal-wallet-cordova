# F-Droid Requirements Checklist

Conceal Mobile is **already published** on F-Droid. Use this checklist when cutting a new Cordova-shell release (templates → `./switch.sh` → commit → push → tag).

## App identity

| Field | Value |
| --- | --- |
| **Package name** | `com.concealnetwork.concealmobile` |
| **Version** | `6.0.5` |
| **Version code** | `56` |
| **License** | MIT |
| **Categories** | Finance, Internet |

Previous: 6.0.4 / 55.

## Build configuration (sdk35 / F-Droid)

| Setting | Value |
| --- | --- |
| Build system | Cordova → Gradle |
| Min SDK | 24 |
| Target SDK | 35 |
| Compile SDK | 36 |
| `android-maxSdkVersion` | **unset** (must not block Android 16+) |

## Repository

- Source: https://github.com/ConcealNetwork/conceal-wallet-cordova
- Issues: https://github.com/ConcealNetwork/conceal-wallet-cordova/issues
- Releases: https://github.com/ConcealNetwork/conceal-wallet-cordova/releases
- fdroiddata recipe: https://gitlab.com/fdroid/fdroiddata (do not edit from casual shell PRs unless intentional)

## Release checklist

- [ ] Templates updated (`configs/sdk35.xml` / `sdk30.xml`) in lockstep for version + versionCode
- [ ] No `android-maxSdkVersion` preference
- [ ] No phantom `READ_CLIPBOARD` / `WRITE_CLIPBOARD` permissions
- [ ] `./switch.sh` regenerated `config.xml` from sdk35 for F-Droid
- [ ] `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt` present
- [ ] `www/` is the intentional Cordova export (do not regenerate casually)
- [ ] Human review, then tag (e.g. `v6.0.5-f-droid`)

## WASM note (issue #17, closed)

`www/**/*.wasm` files are byte-copies of `wasm-pack` output from conceal-lib-js, whitelisted via fdroiddata `scanignore`, loaded over `https://localhost` for streaming instantiation.

## Support

- https://f-droid.org/docs/
- https://gitlab.com/fdroid/fdroiddata
- https://forum.f-droid.org/
