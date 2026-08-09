# Tasks

## 1. Root-cause fix (native plugin)

- [x] 1.1 Enroll: init encrypt cipher, show crypto BiometricPrompt, then doFinal + saveBlob
- [x] 1.2 Align `buildPromptInfo` authenticators with `isBiometricAvailable()`
- [x] 1.3 Remove unused `showPrompt` / `storeSecret` helpers

## 2. Verify

- [x] 2.1 Confirm Java compiles in platform tree after switch.sh
- [x] 2.2 Manual: Settings → Add passkey → biometric prompt → success toast
