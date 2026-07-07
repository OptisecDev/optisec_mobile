package com.optisec.optisec_mobile.applock

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Persists App Lock state (locked package set, PIN salt/hash, failed-attempt
 * lockout, feature-enabled flag) in an EncryptedSharedPreferences file so the
 * PIN material never lands on disk in plaintext.
 */
class AppLockStore(context: Context) {

    private val prefs: SharedPreferences

    init {
        val masterKey = MasterKey.Builder(context.applicationContext)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        prefs = EncryptedSharedPreferences.create(
            context.applicationContext,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
    }

    // ── Feature toggle ────────────────────────────────────────────────
    fun isFeatureEnabled(): Boolean = prefs.getBoolean(KEY_FEATURE_ENABLED, false)

    fun setFeatureEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_FEATURE_ENABLED, enabled).apply()
    }

    // ── Locked packages ──────────────────────────────────────────────
    fun getLockedPackages(): Set<String> = prefs.getStringSet(KEY_LOCKED_PACKAGES, emptySet())
        ?: emptySet()

    fun setLockedPackages(packages: Set<String>) {
        prefs.edit().putStringSet(KEY_LOCKED_PACKAGES, packages).apply()
    }

    // ── PIN ──────────────────────────────────────────────────────────
    fun isPinSet(): Boolean = prefs.contains(KEY_PIN_HASH) && prefs.contains(KEY_PIN_SALT)

    fun setPin(pin: String) {
        val salt = PinHasher.generateSalt()
        val hash = PinHasher.hash(pin, salt)
        prefs.edit()
            .putString(KEY_PIN_SALT, PinHasher.encodeBase64(salt))
            .putString(KEY_PIN_HASH, PinHasher.encodeBase64(hash))
            .putInt(KEY_PIN_ITERATIONS, PinHasher.DEFAULT_ITERATIONS)
            .apply()
        resetFailedAttempts()
    }

    fun clearPin() {
        prefs.edit()
            .remove(KEY_PIN_SALT)
            .remove(KEY_PIN_HASH)
            .remove(KEY_PIN_ITERATIONS)
            .apply()
        resetFailedAttempts()
    }

    fun verifyPin(pin: String): Boolean {
        val saltEncoded = prefs.getString(KEY_PIN_SALT, null) ?: return false
        val hashEncoded = prefs.getString(KEY_PIN_HASH, null) ?: return false
        val iterations = prefs.getInt(KEY_PIN_ITERATIONS, PinHasher.DEFAULT_ITERATIONS)

        val matches = PinHasher.verify(
            pin,
            PinHasher.decodeBase64(saltEncoded),
            iterations,
            PinHasher.decodeBase64(hashEncoded),
        )

        if (matches) resetFailedAttempts() else recordFailedAttempt()
        return matches
    }

    // ── Failed-attempt lockout ───────────────────────────────────────
    // Backoff kicks in after MAX_FREE_ATTEMPTS, doubling per additional
    // attempt from BASE_LOCKOUT_MILLIS, capped at MAX_LOCKOUT_MILLIS.
    fun getFailedAttempts(): Int = prefs.getInt(KEY_FAILED_ATTEMPTS, 0)

    fun getLockoutRemainingMillis(): Long {
        val attempts = getFailedAttempts()
        if (attempts < MAX_FREE_ATTEMPTS) return 0L

        val lastAttempt = prefs.getLong(KEY_LAST_FAILED_TIMESTAMP, 0L)
        if (lastAttempt == 0L) return 0L

        val extra = attempts - MAX_FREE_ATTEMPTS
        val backoff = (BASE_LOCKOUT_MILLIS * (1L shl extra.coerceAtMost(10)))
            .coerceAtMost(MAX_LOCKOUT_MILLIS)

        val elapsed = System.currentTimeMillis() - lastAttempt
        val remaining = backoff - elapsed
        return if (remaining > 0) remaining else 0L
    }

    private fun recordFailedAttempt() {
        prefs.edit()
            .putInt(KEY_FAILED_ATTEMPTS, getFailedAttempts() + 1)
            .putLong(KEY_LAST_FAILED_TIMESTAMP, System.currentTimeMillis())
            .apply()
    }

    fun resetFailedAttempts() {
        prefs.edit()
            .putInt(KEY_FAILED_ATTEMPTS, 0)
            .putLong(KEY_LAST_FAILED_TIMESTAMP, 0L)
            .apply()
    }

    companion object {
        private const val PREFS_FILE_NAME = "app_lock_secure_prefs"

        private const val KEY_FEATURE_ENABLED = "feature_enabled"
        private const val KEY_LOCKED_PACKAGES = "locked_packages"
        private const val KEY_PIN_SALT = "pin_salt"
        private const val KEY_PIN_HASH = "pin_hash"
        private const val KEY_PIN_ITERATIONS = "pin_iterations"
        private const val KEY_FAILED_ATTEMPTS = "failed_attempts"
        private const val KEY_LAST_FAILED_TIMESTAMP = "last_failed_attempt_timestamp"

        const val MAX_FREE_ATTEMPTS = 5
        const val BASE_LOCKOUT_MILLIS = 30_000L
        const val MAX_LOCKOUT_MILLIS = 30L * 60_000L // 30 minutes

        @Volatile
        private var instance: AppLockStore? = null

        fun getInstance(context: Context): AppLockStore =
            instance ?: synchronized(this) {
                instance ?: AppLockStore(context).also { instance = it }
            }
    }
}
