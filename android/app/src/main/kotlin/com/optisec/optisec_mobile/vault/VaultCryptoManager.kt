package com.optisec.optisec_mobile.vault

import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.SecureRandom
import java.security.spec.KeySpec
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec

/**
 * Symmetric crypto primitives for the Password Vault. Follows the same
 * PBKDF2WithHmacSHA256 conventions as [com.optisec.optisec_mobile.applock.PinHasher]
 * (unique salt, iteration count stored alongside it so it can be raised
 * later without invalidating existing vaults) plus AES-256-GCM for both key
 * wrapping and per-entry encryption.
 *
 * Two secrets are ever derived here: the master-password KEK (never
 * persisted, exists only for the duration of a wrap/unwrap call) and the
 * random per-vault DEK (persisted only in wrapped form). All entry content
 * is encrypted under the DEK, never under the KEK directly, so rotating the
 * master password only requires re-wrapping the DEK.
 */
object VaultCryptoManager {
    const val SALT_LENGTH_BYTES = 16
    const val DEFAULT_ITERATIONS = 300_000
    const val KEY_LENGTH_BITS = 256

    private const val GCM_IV_LENGTH_BYTES = 12
    private const val GCM_TAG_LENGTH_BITS = 128
    private const val AES_TRANSFORMATION = "AES/GCM/NoPadding"

    /** Combined IV + ciphertext (which already includes the GCM tag), each base64-encoded. */
    data class EncryptedBlob(val ivBase64: String, val cipherTextBase64: String) {
        fun serialize(): String = "$ivBase64.$cipherTextBase64"

        companion object {
            fun deserialize(serialized: String): EncryptedBlob {
                val parts = serialized.split(".", limit = 2)
                require(parts.size == 2) { "Malformed encrypted blob" }
                return EncryptedBlob(parts[0], parts[1])
            }
        }
    }

    fun generateSalt(): ByteArray {
        val salt = ByteArray(SALT_LENGTH_BYTES)
        SecureRandom().nextBytes(salt)
        return salt
    }

    /** Derives the master-password KEK. Never persisted — used immediately then discarded. */
    fun deriveKek(password: CharArray, salt: ByteArray, iterations: Int = DEFAULT_ITERATIONS): SecretKey {
        val spec: KeySpec = PBEKeySpec(password, salt, iterations, KEY_LENGTH_BITS)
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        val keyBytes = factory.generateSecret(spec).encoded
        return SecretKeySpec(keyBytes, KeyProperties.KEY_ALGORITHM_AES)
    }

    /** Generates a fresh random AES-256 data-encryption key for a new vault. */
    fun generateDek(): SecretKey {
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES)
        generator.init(KEY_LENGTH_BITS, SecureRandom())
        return generator.generateKey()
    }

    fun keyFromBytes(bytes: ByteArray): SecretKey = SecretKeySpec(bytes, KeyProperties.KEY_ALGORITHM_AES)

    /** Encrypts arbitrary bytes under [key] with a fresh random IV. Used for both entry data and key wrapping. */
    fun encrypt(plaintext: ByteArray, key: SecretKey): EncryptedBlob {
        val iv = ByteArray(GCM_IV_LENGTH_BYTES)
        SecureRandom().nextBytes(iv)
        val cipher = Cipher.getInstance(AES_TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
        val cipherText = cipher.doFinal(plaintext)
        return EncryptedBlob(encodeBase64(iv), encodeBase64(cipherText))
    }

    /**
     * Decrypts [blob] under [key]. Throws (typically
     * [javax.crypto.AEADBadTagException]) if [key] is wrong or the blob was
     * tampered with — the GCM tag itself is the integrity/authenticity check,
     * so callers can treat any exception here as "wrong password / corrupt data".
     */
    fun decrypt(blob: EncryptedBlob, key: SecretKey): ByteArray {
        val iv = decodeBase64(blob.ivBase64)
        val cipherText = decodeBase64(blob.cipherTextBase64)
        val cipher = Cipher.getInstance(AES_TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
        return cipher.doFinal(cipherText)
    }

    fun wrapKey(keyToWrap: SecretKey, wrappingKey: SecretKey): EncryptedBlob =
        encrypt(keyToWrap.encoded, wrappingKey)

    fun unwrapKey(blob: EncryptedBlob, wrappingKey: SecretKey): SecretKey =
        keyFromBytes(decrypt(blob, wrappingKey))

    fun encodeBase64(bytes: ByteArray): String = Base64.encodeToString(bytes, Base64.NO_WRAP)

    fun decodeBase64(encoded: String): ByteArray = Base64.decode(encoded, Base64.NO_WRAP)
}
