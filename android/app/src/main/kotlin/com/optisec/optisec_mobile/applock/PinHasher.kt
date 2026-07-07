package com.optisec.optisec_mobile.applock

import android.util.Base64
import java.security.SecureRandom
import java.security.spec.KeySpec
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec

/**
 * PIN hashing via PBKDF2WithHmacSHA256. The salt is unique per PIN and the
 * iteration count is stored alongside the hash so it can be raised in a
 * future release without invalidating PINs set under a lower count.
 */
object PinHasher {
    const val SALT_LENGTH_BYTES = 16
    const val DEFAULT_ITERATIONS = 120_000
    const val KEY_LENGTH_BITS = 256

    fun generateSalt(): ByteArray {
        val salt = ByteArray(SALT_LENGTH_BYTES)
        SecureRandom().nextBytes(salt)
        return salt
    }

    fun hash(pin: String, salt: ByteArray, iterations: Int = DEFAULT_ITERATIONS): ByteArray {
        val spec: KeySpec = PBEKeySpec(pin.toCharArray(), salt, iterations, KEY_LENGTH_BITS)
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        return factory.generateSecret(spec).encoded
    }

    fun verify(pin: String, salt: ByteArray, iterations: Int, expectedHash: ByteArray): Boolean {
        val candidate = hash(pin, salt, iterations)
        return constantTimeEquals(candidate, expectedHash)
    }

    fun encodeBase64(bytes: ByteArray): String = Base64.encodeToString(bytes, Base64.NO_WRAP)

    fun decodeBase64(encoded: String): ByteArray = Base64.decode(encoded, Base64.NO_WRAP)

    private fun constantTimeEquals(a: ByteArray, b: ByteArray): Boolean {
        if (a.size != b.size) return false
        var result = 0
        for (i in a.indices) {
            result = result or (a[i].toInt() xor b[i].toInt())
        }
        return result == 0
    }
}
