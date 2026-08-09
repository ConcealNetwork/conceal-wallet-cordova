# cordova-plugin-biometric-unlock

Native biometric unlock for **Conceal Mobile** (Android APK).

## Why a custom plugin?

Cordova/npm has plugins that **show a biometric dialog**, but none that match
what Conceal Wallet needs:

| Existing option | What it does | Why it is not enough |
|-----------------|--------------|----------------------|
| `cordova-plugin-fingerprint-aio` | Fingerprint/face **yes/no** prompt | No secret lifecycle — cannot derive a stable 32-byte key for AES-GCM |
| WebAuthn in Android WebView | Passkey ceremonies in **browsers** | **Missing or incomplete** in Cordova WebView (`PublicKeyCredential` absent); Android browser often lacks **PRF** |
| Passkey / WebAuthn polyfill | Fake `PublicKeyCredential` in JS | Rejected — breaks iOS PWA, wrong security model |

Conceal encrypts the wallet password with a **32-byte secret** (same as WebAuthn
PRF + `encryptWithSecret` in the web wallet). This plugin:

1. Runs **BiometricPrompt** (AndroidX)
2. Gates a **Keystore AES key** behind biometrics
3. Returns the secret to JS **only after** a successful assertion
4. Stores ciphertext in SharedPreferences + key alias per credential id

That contract is **app-specific** — not a generic Cordova feature — so a small
tracked plugin under `cordova-plugins/` is the right layer (not a polyfill).

## JS API (`cordova.plugins.biometricUnlock`)

- `isAvailable()` → boolean
- `enroll()` → `{ credentialId, secretBase64url }`
- `unlock(credentialId)` → `{ secretBase64url }`
- `remove(credentialId)`

The wallet adapter lives in `conceal-next-wallet` (`lib/auth/platform-unlock.ts`).

## Rebuild

After changing native code, run `./switch.sh` (copies plugin into `platforms/android`).
