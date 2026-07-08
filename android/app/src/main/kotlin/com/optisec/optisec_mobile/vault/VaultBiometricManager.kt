package com.optisec.optisec_mobile.vault

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Wraps a second copy of the vault DEK behind a Keystore AES key that
 * requires fresh biometric authentication for every use
 * (`setUserAuthenticationRequired(true)`, no auth-validity window — the
 * Cipher itself is the CryptoObject BiometricPrompt authenticates, so a
 * successful prompt is required per encrypt/decrypt call, not just once per
 * unlock window). The key is invalidated automatically if the user adds or
 * removes a fingerprint/face, and is StrongBox-backed when the device
 * supports it, falling back transparently otherwise.
 *
 * Callers must only invoke [enroll] after the caller has already verified
 * the master password for this session — this class has no opinion on that,
 * it just wraps/unwraps whatever [SecretKey] it's handed.
 */
class VaultBiometricManager {

    fun canUseBiometric(activity: FragmentActivity): Boolean {
        val manager = BiometricManager.from(activity)
        return manager.canAuthenticate(AUTHENTICATORS) == BiometricManager.BIOMETRIC_SUCCESS
    }

    /** Encrypts [dek] under the biometric Keystore key, prompting for authentication first. */
    fun enroll(
        activity: FragmentActivity,
        dek: SecretKey,
        onSuccess: (VaultCryptoManager.EncryptedBlob) -> Unit,
        onError: (String) -> Unit,
    ) {
        val cipher = try {
            val key = getOrCreateKey()
            Cipher.getInstance(AES_TRANSFORMATION).apply {
                init(Cipher.ENCRYPT_MODE, key)
            }
        } catch (e: Exception) {
            onError(e.message ?: "Could not prepare biometric key")
            return
        }

        authenticate(activity, cipher, onError) { authenticatedCipher ->
            try {
                val iv = authenticatedCipher.iv
                val cipherText = authenticatedCipher.doFinal(dek.encoded)
                onSuccess(
                    VaultCryptoManager.EncryptedBlob(
                        VaultCryptoManager.encodeBase64(iv),
                        VaultCryptoManager.encodeBase64(cipherText),
                    ),
                )
            } catch (e: Exception) {
                onError(e.message ?: "Biometric enrollment failed")
            }
        }
    }

    /** Decrypts the stored biometric-wrapped DEK, prompting for authentication first. */
    fun unlock(
        activity: FragmentActivity,
        wrapped: VaultCryptoManager.EncryptedBlob,
        onSuccess: (SecretKey) -> Unit,
        onError: (String) -> Unit,
        onKeyInvalidated: () -> Unit,
    ) {
        val cipher = try {
            val key = getExistingKey() ?: run {
                onKeyInvalidated()
                return
            }
            val iv = VaultCryptoManager.decodeBase64(wrapped.ivBase64)
            Cipher.getInstance(AES_TRANSFORMATION).apply {
                init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
            }
        } catch (_: KeyPermanentlyInvalidatedException) {
            onKeyInvalidated()
            return
        } catch (e: Exception) {
            onError(e.message ?: "Could not prepare biometric key")
            return
        }

        authenticate(activity, cipher, onError) { authenticatedCipher ->
            try {
                val cipherText = VaultCryptoManager.decodeBase64(wrapped.cipherTextBase64)
                val dekBytes = authenticatedCipher.doFinal(cipherText)
                onSuccess(VaultCryptoManager.keyFromBytes(dekBytes))
            } catch (e: Exception) {
                onError(e.message ?: "Biometric unlock failed")
            }
        }
    }

    fun deleteKey() {
        try {
            val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
            if (keyStore.containsAlias(KEY_ALIAS)) keyStore.deleteEntry(KEY_ALIAS)
        } catch (_: Exception) {
            // Nothing actionable if the key is already gone.
        }
    }

    private fun authenticate(
        activity: FragmentActivity,
        cipher: Cipher,
        onError: (String) -> Unit,
        onAuthenticated: (Cipher) -> Unit,
    ) {
        val executor = ContextCompat.getMainExecutor(activity)
        val prompt = BiometricPrompt(
            activity,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    val authenticatedCipher = result.cryptoObject?.cipher
                    if (authenticatedCipher == null) {
                        onError("No authenticated cipher returned")
                    } else {
                        onAuthenticated(authenticatedCipher)
                    }
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    onError(errString.toString())
                }

                override fun onAuthenticationFailed() {
                    // System dialog stays open and lets the user retry on its own.
                }
            },
        )

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Unlock Password Vault")
            .setSubtitle("Confirm your identity to continue")
            .setNegativeButtonText("Cancel")
            .setAllowedAuthenticators(AUTHENTICATORS)
            .build()

        prompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(cipher))
    }

    private fun getOrCreateKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        keyStore.getKey(KEY_ALIAS, null)?.let { return it as SecretKey }

        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val specBuilder = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(VaultCryptoManager.KEY_LENGTH_BITS)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(true)

        generator.init(tryStrongBox(specBuilder))
        return generator.generateKey()
    }

    private fun tryStrongBox(builder: KeyGenParameterSpec.Builder): KeyGenParameterSpec {
        return try {
            builder.setIsStrongBoxBacked(true).build()
        } catch (_: Exception) {
            builder.setIsStrongBoxBacked(false).build()
        }
    }

    private fun getExistingKey(): SecretKey? {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        return keyStore.getKey(KEY_ALIAS, null) as? SecretKey
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "optisec_vault_biometric_key"
        private const val AES_TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_LENGTH_BITS = 128
        private const val AUTHENTICATORS =
            BiometricManager.Authenticators.BIOMETRIC_STRONG
    }
}
