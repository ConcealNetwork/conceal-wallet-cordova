# Fix biometric enroll crypto flow

## Why

Enroll calls `storeSecret()` before BiometricPrompt. Keystore keys with
`userAuthenticationRequired` reject `cipher.doFinal()` until the user verifies.
Native returns `"failed"` immediately; wallet shows "Biometric unlock failed".

## What Changes

- Enroll uses `BiometricPrompt` + `CryptoObject` (same pattern as unlock).
- Prompt + Keystore use Class 3 (`BIOMETRIC_STRONG` / `AUTH_BIOMETRIC_STRONG` only; weak has no Keystore crypto support).
- Remove dead `showPrompt` / pre-auth `storeSecret` path.

## Capabilities

- `cordova-biometric-unlock`: enroll/unlock contract unchanged at JS boundary.

## Impact

- `cordova-plugins/cordova-plugin-biometric-unlock/src/android/BiometricUnlock.java` only.
- Rebuild via `./switch.sh` to copy into `platforms/android`.
