package com.optisec.optisec_mobile.vault

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import javax.crypto.SecretKey
import org.json.JSONObject
import java.util.UUID

/**
 * Persists Password Vault state in its own EncryptedSharedPreferences file,
 * mirroring [com.optisec.optisec_mobile.applock.AppLockStore]. Nothing sensitive
 * here is ever stored in plaintext: the DEK only ever touches disk wrapped
 * (once under the master-password KEK, optionally a second time under the
 * biometric Keystore key), and every entry field beyond its opaque id is
 * encrypted under the DEK before being written.
 *
 * The unwrapped DEK is cached in memory only ([cachedDek]) for the duration
 * of an unlocked session — cleared on explicit lock, auto-lock, or process
 * death. It is never itself persisted.
 */
class VaultStore(context: Context) {

    private val prefs: SharedPreferences

    @Volatile
    private var cachedDek: SecretKey? = null

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

    // ── Vault lifecycle ──────────────────────────────────────────────
    fun isVaultInitialized(): Boolean =
        prefs.contains(KEY_MASTER_SALT) && prefs.contains(KEY_WRAPPED_DEK)

    /** Creates a brand-new vault: fresh salt + DEK, DEK wrapped under the master-password KEK. */
    fun setupVault(masterPassword: CharArray, iterations: Int = VaultCryptoManager.DEFAULT_ITERATIONS): SecretKey {
        val salt = VaultCryptoManager.generateSalt()
        val kek = VaultCryptoManager.deriveKek(masterPassword, salt, iterations)
        // Zero the caller's CharArray now that the KEK has been derived
        // from it -- it isn't read again below.
        masterPassword.fill('\u0000')
        val dek = VaultCryptoManager.generateDek()
        val wrapped = VaultCryptoManager.wrapKey(dek, kek)

        prefs.edit()
            .putString(KEY_MASTER_SALT, VaultCryptoManager.encodeBase64(salt))
            .putInt(KEY_MASTER_ITERATIONS, iterations)
            .putString(KEY_WRAPPED_DEK, wrapped.serialize())
            .putStringSet(KEY_ENTRY_IDS, emptySet())
            .apply()
        resetFailedAttempts()
        cacheDek(dek)
        return dek
    }

    /**
     * Verifies [masterPassword] by attempting to unwrap the stored DEK — the
     * GCM tag check inside [VaultCryptoManager.unwrapKey] *is* the
     * verification, there is no separate password hash. Records/resets the
     * failed-attempt counter exactly like [com.optisec.optisec_mobile.applock.AppLockStore.verifyPin].
     */
    fun unlockWithMasterPassword(masterPassword: CharArray): SecretKey? {
        val saltEncoded = prefs.getString(KEY_MASTER_SALT, null) ?: return null
        val wrappedEncoded = prefs.getString(KEY_WRAPPED_DEK, null) ?: return null
        val iterations = prefs.getInt(KEY_MASTER_ITERATIONS, VaultCryptoManager.DEFAULT_ITERATIONS)

        val salt = VaultCryptoManager.decodeBase64(saltEncoded)
        val kek = VaultCryptoManager.deriveKek(masterPassword, salt, iterations)
        // Zero the caller's CharArray now that the KEK has been derived
        // from it -- it isn't read again below.
        masterPassword.fill('\u0000')

        val dek = try {
            VaultCryptoManager.unwrapKey(VaultCryptoManager.EncryptedBlob.deserialize(wrappedEncoded), kek)
        } catch (_: Exception) {
            null
        }

        if (dek != null) {
            resetFailedAttempts()
            cacheDek(dek)
        } else {
            recordFailedAttempt()
        }
        return dek
    }

    // ── In-memory session ────────────────────────────────────────────
    fun cacheDek(dek: SecretKey) {
        cachedDek = dek
    }

    fun getCachedDek(): SecretKey? = cachedDek

    fun isUnlocked(): Boolean = cachedDek != null

    fun lockSession() {
        cachedDek = null
    }

    // ── Biometric-wrapped DEK ────────────────────────────────────────
    fun isBiometricEnabled(): Boolean = prefs.getBoolean(KEY_BIOMETRIC_ENABLED, false) &&
        prefs.contains(KEY_BIOMETRIC_WRAPPED_DEK)

    fun getBiometricWrappedDek(): VaultCryptoManager.EncryptedBlob? {
        val encoded = prefs.getString(KEY_BIOMETRIC_WRAPPED_DEK, null) ?: return null
        return VaultCryptoManager.EncryptedBlob.deserialize(encoded)
    }

    fun setBiometricWrappedDek(blob: VaultCryptoManager.EncryptedBlob) {
        prefs.edit()
            .putString(KEY_BIOMETRIC_WRAPPED_DEK, blob.serialize())
            .putBoolean(KEY_BIOMETRIC_ENABLED, true)
            .apply()
    }

    fun clearBiometricWrappedDek() {
        prefs.edit()
            .remove(KEY_BIOMETRIC_WRAPPED_DEK)
            .putBoolean(KEY_BIOMETRIC_ENABLED, false)
            .apply()
    }

    // ── Failed-attempt lockout — identical policy to AppLockStore ────
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

    // ── Auto-lock timeout ─────────────────────────────────────────────
    fun getAutoLockTimeoutMillis(): Long = prefs.getLong(KEY_AUTO_LOCK_TIMEOUT_MILLIS, DEFAULT_AUTO_LOCK_MILLIS)

    fun setAutoLockTimeoutMillis(millis: Long) {
        prefs.edit().putLong(KEY_AUTO_LOCK_TIMEOUT_MILLIS, millis).apply()
    }

    // ── Entries ───────────────────────────────────────────────────────
    fun entryIds(): Set<String> = prefs.getStringSet(KEY_ENTRY_IDS, emptySet()) ?: emptySet()

    fun entryCount(): Int = entryIds().size

    /** Metadata only (no password) — safe to hand to the list screen in bulk. */
    fun listEntryMetadata(dek: SecretKey): List<Map<String, Any?>> =
        entryIds().mapNotNull { id -> readMetadata(id, dek) }
            .sortedByDescending { it["updatedAt"] as? Long ?: 0L }

    /**
     * Returns the decrypted password as a [CharArray] rather than a
     * [String] so the caller can zero it (`Arrays.fill`) once it's been
     * handed off — a plain [String] result can't be wiped, since JVM
     * strings are immutable. The `org.json` parse below still produces one
     * short-lived, unzeroable String internally (org.json's API only
     * accepts/returns String); that's an inherent limitation of that
     * library, not something this change can reach further into without
     * replacing the JSON parser entirely.
     */
    fun getEntryPassword(id: String, dek: SecretKey): CharArray? {
        val encoded = prefs.getString(secretKeyFor(id), null) ?: return null
        val bytes = VaultCryptoManager.decrypt(VaultCryptoManager.EncryptedBlob.deserialize(encoded), dek)
        return JSONObject(String(bytes, Charsets.UTF_8)).getString("password").toCharArray()
    }

    /**
     * Full decrypted record including password — used only by the native
     * export path ([VaultExportImportManager.exportVault]). The password
     * has to be converted back to a String here (rather than staying a
     * CharArray) because it's about to be embedded in an `org.json`
     * `JSONObject`/`JSONArray`, which only knows how to serialize Strings —
     * handing it a CharArray would silently serialize as Java's default
     * `Object.toString()` (e.g. `[C@1a2b3c`) instead of the password text.
     */
    fun getFullEntry(id: String, dek: SecretKey): Map<String, Any?>? {
        val meta = readMetadata(id, dek) ?: return null
        val passwordChars = getEntryPassword(id, dek) ?: return null
        val password = String(passwordChars)
        passwordChars.fill('\u0000')
        return meta + mapOf("password" to password)
    }

    fun getAllEntriesDecrypted(dek: SecretKey): List<Map<String, Any?>> =
        entryIds().mapNotNull { id -> getFullEntry(id, dek) }

    /** Creates a new entry (id == null) or updates an existing one, returning its id. */
    fun upsertEntry(
        id: String?,
        title: String,
        username: String,
        url: String,
        notes: String,
        password: String,
        dek: SecretKey,
    ): String {
        val now = System.currentTimeMillis()
        val existing = id?.let { readMetadata(it, dek) }
        val entryId = id ?: UUID.randomUUID().toString()
        val createdAt = existing?.get("createdAt") as? Long ?: now

        val metaJson = JSONObject().apply {
            put("id", entryId)
            put("title", title)
            put("username", username)
            put("url", url)
            put("notes", notes)
            put("createdAt", createdAt)
            put("updatedAt", now)
        }
        val secretJson = JSONObject().apply { put("password", password) }

        val metaBlob = VaultCryptoManager.encrypt(metaJson.toString().toByteArray(Charsets.UTF_8), dek)
        val secretBlob = VaultCryptoManager.encrypt(secretJson.toString().toByteArray(Charsets.UTF_8), dek)

        prefs.edit()
            .putString(metaKeyFor(entryId), metaBlob.serialize())
            .putString(secretKeyFor(entryId), secretBlob.serialize())
            .putStringSet(KEY_ENTRY_IDS, entryIds() + entryId)
            .apply()

        return entryId
    }

    fun deleteEntry(id: String) {
        prefs.edit()
            .remove(metaKeyFor(id))
            .remove(secretKeyFor(id))
            .putStringSet(KEY_ENTRY_IDS, entryIds() - id)
            .apply()
    }

    fun wipeAllEntries() {
        val editor = prefs.edit()
        for (id in entryIds()) {
            editor.remove(metaKeyFor(id)).remove(secretKeyFor(id))
        }
        editor.putStringSet(KEY_ENTRY_IDS, emptySet()).apply()
    }

    private fun readMetadata(id: String, dek: SecretKey): Map<String, Any?>? {
        val encoded = prefs.getString(metaKeyFor(id), null) ?: return null
        val bytes = try {
            VaultCryptoManager.decrypt(VaultCryptoManager.EncryptedBlob.deserialize(encoded), dek)
        } catch (_: Exception) {
            return null
        }
        val json = JSONObject(String(bytes, Charsets.UTF_8))
        return mapOf(
            "id" to json.getString("id"),
            "title" to json.getString("title"),
            "username" to json.optString("username", ""),
            "url" to json.optString("url", ""),
            "notes" to json.optString("notes", ""),
            "createdAt" to json.getLong("createdAt"),
            "updatedAt" to json.getLong("updatedAt"),
        )
    }

    private fun metaKeyFor(id: String) = "entry_meta_$id"
    private fun secretKeyFor(id: String) = "entry_secret_$id"

    companion object {
        const val PREFS_FILE_NAME = "password_vault_secure_prefs"

        private const val KEY_MASTER_SALT = "master_salt"
        private const val KEY_MASTER_ITERATIONS = "master_iterations"
        private const val KEY_WRAPPED_DEK = "wrapped_dek"
        private const val KEY_BIOMETRIC_WRAPPED_DEK = "biometric_wrapped_dek"
        private const val KEY_BIOMETRIC_ENABLED = "biometric_enabled"
        private const val KEY_FAILED_ATTEMPTS = "failed_attempts"
        private const val KEY_LAST_FAILED_TIMESTAMP = "last_failed_attempt_timestamp"
        private const val KEY_AUTO_LOCK_TIMEOUT_MILLIS = "auto_lock_timeout_millis"
        private const val KEY_ENTRY_IDS = "entry_ids"

        const val MAX_FREE_ATTEMPTS = 5
        const val BASE_LOCKOUT_MILLIS = 30_000L
        const val MAX_LOCKOUT_MILLIS = 30L * 60_000L // 30 minutes

        const val DEFAULT_AUTO_LOCK_MILLIS = 60_000L // 1 minute

        @Volatile
        private var instance: VaultStore? = null

        fun getInstance(context: Context): VaultStore =
            instance ?: synchronized(this) {
                instance ?: VaultStore(context).also { instance = it }
            }
    }
}
