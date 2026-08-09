package network.conceal.biometricunlock;

import android.content.SharedPreferences;
import android.os.Build;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.biometric.BiometricManager;
import androidx.biometric.BiometricPrompt;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import java.security.KeyStore;
import java.security.SecureRandom;
import java.util.concurrent.Executor;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

/**
 * Stores a per-credential 32-byte unlock secret in Android Keystore (biometric-gated)
 * and returns it to the WebView after a successful BiometricPrompt assertion — the
 * same contract as WebAuthn PRF + encryptWithSecret in the wallet.
 */
public class BiometricUnlock extends CordovaPlugin {
    private static final String PREFS = "conceal_biometric_unlock";
    private static final String KEYSTORE = "AndroidKeyStore";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int SECRET_LENGTH = 32;
    private static final int CREDENTIAL_ID_LENGTH = 16;

    private CallbackContext pendingCallback;

    @Override
    public boolean execute(String action, org.apache.cordova.CordovaArgs args, CallbackContext callbackContext) {
        switch (action) {
            case "isAvailable":
                callbackContext.sendPluginResult(
                        new PluginResult(PluginResult.Status.OK, isBiometricAvailable() ? 1 : 0));
                return true;
            case "enroll":
                enroll(callbackContext);
                return true;
            case "unlock":
                try {
                    unlock(args.getString(0), callbackContext);
                } catch (JSONException e) {
                    callbackContext.error("invalid credential id");
                }
                return true;
            case "remove":
                try {
                    remove(args.getString(0), callbackContext);
                } catch (JSONException e) {
                    callbackContext.error("invalid credential id");
                }
                return true;
            default:
                return false;
        }
    }

    private boolean isBiometricAvailable() {
        BiometricManager manager = BiometricManager.from(cordova.getContext());
        int authenticators = BiometricManager.Authenticators.BIOMETRIC_STRONG;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            authenticators |= BiometricManager.Authenticators.DEVICE_CREDENTIAL;
        }
        return manager.canAuthenticate(authenticators) == BiometricManager.BIOMETRIC_SUCCESS;
    }

    private void enroll(CallbackContext callbackContext) {
        if (!isBiometricAvailable()) {
            callbackContext.error("unsupported");
            return;
        }

        cordova.getThreadPool().execute(() -> {
            String credentialId = null;
            try {
                credentialId = randomBase64Url(CREDENTIAL_ID_LENGTH);
                byte[] secret = randomBytes(SECRET_LENGTH);
                SecretKey key = createKey(credentialId);
                Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
                cipher.init(Cipher.ENCRYPT_MODE, key);

                final String id = credentialId;
                final byte[] secretCopy = secret.clone();
                final Cipher encryptCipher = cipher;

                cordova.getActivity().runOnUiThread(() ->
                        showCryptoPrompt(
                                callbackContext,
                                "Enable biometric unlock",
                                "Confirm with your fingerprint or face",
                                encryptCipher,
                                () -> {
                                    try {
                                        byte[] iv = encryptCipher.getIV();
                                        byte[] ciphertext = encryptCipher.doFinal(secretCopy);
                                        saveBlob(id, iv, ciphertext);
                                        JSONObject result = new JSONObject();
                                        result.put("credentialId", id);
                                        result.put("secretBase64url", base64UrlEncode(secretCopy));
                                        callbackContext.success(result);
                                    } catch (Exception e) {
                                        removeStoredCredential(id);
                                        callbackContext.error("failed");
                                    }
                                },
                                () -> {
                                    removeStoredCredential(id);
                                    callbackContext.error("cancelled");
                                }));
            } catch (Exception e) {
                if (credentialId != null) {
                    removeStoredCredential(credentialId);
                }
                callbackContext.error("failed");
            }
        });
    }

    private void unlock(String credentialId, CallbackContext callbackContext) {
        if (!isBiometricAvailable()) {
            callbackContext.error("unsupported");
            return;
        }
        if (credentialId == null || credentialId.isEmpty()) {
            callbackContext.error("failed");
            return;
        }

        cordova.getThreadPool().execute(() -> {
            try {
                EncryptedBlob blob = loadBlob(credentialId);
                if (blob == null) {
                    callbackContext.error("failed");
                    return;
                }
                Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
                GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, blob.iv);
                SecretKey key = loadKey(credentialId);
                cipher.init(Cipher.DECRYPT_MODE, key, spec);

                cordova.getActivity().runOnUiThread(() ->
                        showCryptoPrompt(
                                callbackContext,
                                "Unlock wallet",
                                "Use biometrics to unlock",
                                cipher,
                                () -> {
                                    try {
                                        byte[] secret = cipher.doFinal(blob.ciphertext);
                                        JSONObject result = new JSONObject();
                                        result.put("secretBase64url", base64UrlEncode(secret));
                                        callbackContext.success(result);
                                    } catch (Exception e) {
                                        callbackContext.error("failed");
                                    }
                                },
                                () -> callbackContext.error("cancelled")));
            } catch (Exception e) {
                callbackContext.error("failed");
            }
        });
    }

    private void remove(String credentialId, CallbackContext callbackContext) {
        cordova.getThreadPool().execute(() -> {
            removeStoredCredential(credentialId);
            callbackContext.success();
        });
    }

    private SecretKey createKey(String credentialId) throws Exception {
        String alias = keystoreAlias(credentialId);
        KeyStore keyStore = KeyStore.getInstance(KEYSTORE);
        keyStore.load(null);
        if (keyStore.containsAlias(alias)) {
            keyStore.deleteEntry(alias);
        }

        KeyGenerator generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE);
        KeyGenParameterSpec.Builder builder = new KeyGenParameterSpec.Builder(
                alias,
                KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setUserAuthenticationRequired(true);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Keystore auth-per-use keys only support Class 3 (strong) biometrics.
            builder.setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG);
        } else {
            builder.setUserAuthenticationValidityDurationSeconds(-1);
        }

        generator.init(builder.build());
        return generator.generateKey();
    }

    private SecretKey loadKey(String credentialId) throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEYSTORE);
        keyStore.load(null);
        KeyStore.SecretKeyEntry entry =
                (KeyStore.SecretKeyEntry) keyStore.getEntry(keystoreAlias(credentialId), null);
        return entry.getSecretKey();
    }

    private void saveBlob(String credentialId, byte[] iv, byte[] ciphertext) {
        SharedPreferences prefs = cordova.getContext().getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE);
        prefs.edit()
                .putString(prefKey(credentialId, "iv"), base64UrlEncode(iv))
                .putString(prefKey(credentialId, "ct"), base64UrlEncode(ciphertext))
                .apply();
    }

    private EncryptedBlob loadBlob(String credentialId) {
        SharedPreferences prefs = cordova.getContext().getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE);
        String iv = prefs.getString(prefKey(credentialId, "iv"), null);
        String ct = prefs.getString(prefKey(credentialId, "ct"), null);
        if (iv == null || ct == null) {
            return null;
        }
        return new EncryptedBlob(base64UrlDecode(iv), base64UrlDecode(ct));
    }

    private void removeStoredCredential(String credentialId) {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEYSTORE);
            keyStore.load(null);
            String alias = keystoreAlias(credentialId);
            if (keyStore.containsAlias(alias)) {
                keyStore.deleteEntry(alias);
            }
        } catch (Exception ignored) {
            // best-effort
        }
        SharedPreferences prefs = cordova.getContext().getSharedPreferences(PREFS, android.content.Context.MODE_PRIVATE);
        prefs.edit()
                .remove(prefKey(credentialId, "iv"))
                .remove(prefKey(credentialId, "ct"))
                .apply();
    }

    private void showCryptoPrompt(
            CallbackContext callbackContext,
            String title,
            String subtitle,
            Cipher cipher,
            Runnable onSuccess,
            Runnable onError) {
        FragmentActivity activity = requireFragmentActivity(callbackContext);
        if (activity == null) {
            return;
        }
        pendingCallback = callbackContext;
        Executor executor = ContextCompat.getMainExecutor(activity);
        BiometricPrompt prompt = new BiometricPrompt(
                activity,
                executor,
                new BiometricPrompt.AuthenticationCallback() {
                    @Override
                    public void onAuthenticationSucceeded(@NonNull BiometricPrompt.AuthenticationResult result) {
                        pendingCallback = null;
                        onSuccess.run();
                    }

                    @Override
                    public void onAuthenticationError(int errorCode, @NonNull CharSequence errString) {
                        pendingCallback = null;
                        onError.run();
                    }

                    @Override
                    public void onAuthenticationFailed() {
                        // Keep the dialog open until success or explicit cancel.
                    }
                });

        BiometricPrompt.CryptoObject cryptoObject = new BiometricPrompt.CryptoObject(cipher);
        prompt.authenticate(buildPromptInfo(title, subtitle), cryptoObject);
    }

    private BiometricPrompt.PromptInfo buildPromptInfo(String title, String subtitle) {
        BiometricPrompt.PromptInfo.Builder builder = new BiometricPrompt.PromptInfo.Builder()
                .setTitle(title)
                .setSubtitle(subtitle)
                .setNegativeButtonText("Cancel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG);
        }
        return builder.build();
    }

    private FragmentActivity requireFragmentActivity(CallbackContext callbackContext) {
        if (!(cordova.getActivity() instanceof FragmentActivity)) {
            callbackContext.error("failed");
            return null;
        }
        return (FragmentActivity) cordova.getActivity();
    }

    private static String keystoreAlias(String credentialId) {
        return "conceal_bio_" + credentialId.replaceAll("[^A-Za-z0-9_-]", "_");
    }

    private static String prefKey(String credentialId, String suffix) {
        return "cred_" + credentialId + "_" + suffix;
    }

    private static String randomBase64Url(int length) {
        return base64UrlEncode(randomBytes(length));
    }

    private static byte[] randomBytes(int length) {
        byte[] bytes = new byte[length];
        new SecureRandom().nextBytes(bytes);
        return bytes;
    }

    private static String base64UrlEncode(byte[] bytes) {
        return Base64.encodeToString(bytes, Base64.URL_SAFE | Base64.NO_WRAP | Base64.NO_PADDING);
    }

    private static byte[] base64UrlDecode(String value) {
        return Base64.decode(value, Base64.URL_SAFE | Base64.NO_PADDING);
    }

    private static final class EncryptedBlob {
        final byte[] iv;
        final byte[] ciphertext;

        EncryptedBlob(byte[] iv, byte[] ciphertext) {
            this.iv = iv;
            this.ciphertext = ciphertext;
        }
    }
}
