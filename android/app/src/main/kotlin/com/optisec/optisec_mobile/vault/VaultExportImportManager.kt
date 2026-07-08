package com.optisec.optisec_mobile.vault

import com.optisec.optisec_mobile.MainActivity
import io.flutter.plugin.common.MethodChannel
import javax.crypto.SecretKey
import org.json.JSONArray
import org.json.JSONObject

/**
 * Export/import for the Password Vault via the Storage Access Framework.
 * Export re-derives the DEK from the *master* password (re-auth — a
 * currently-unlocked session is not sufficient on its own to export), then
 * re-encrypts the full decrypted entry set under a key derived from a
 * separate, user-chosen *export* password. No plaintext or DEK-encrypted
 * intermediate ever touches disk: the JSON payload is built in memory,
 * encrypted in memory, and only the final ciphertext container is written
 * to the SAF-picked [android.net.Uri].
 *
 * The `.opsvault` container is plain JSON: `{format, version, salt,
 * iterations, iv, cipherText}`, where `cipherText` is the AES-256-GCM
 * encryption (under a PBKDF2-derived key from the export password) of the
 * serialized entry list. The GCM tag on that outer layer is what detects a
 * wrong export password or a corrupted/tampered file on import.
 */
class VaultExportImportManager(private val activity: MainActivity, private val store: VaultStore) {

    fun exportVault(masterPassword: CharArray, exportPassword: String, result: MethodChannel.Result) {
        if (!isExportPasswordStrongEnough(exportPassword)) {
            result.error(
                "WEAK_EXPORT_PASSWORD",
                "Export password must be at least 10 characters and mix character types",
                null,
            )
            return
        }

        val dek = store.unlockWithMasterPassword(masterPassword)
        if (dek == null) {
            result.error("REAUTH_FAILED", "Incorrect master password", null)
            return
        }

        val entries = store.getAllEntriesDecrypted(dek)
        val payload = JSONObject().apply {
            put("version", 1)
            put("exportedAt", System.currentTimeMillis())
            put("entries", JSONArray(entries))
        }

        val salt = VaultCryptoManager.generateSalt()
        val iterations = VaultCryptoManager.DEFAULT_ITERATIONS
        val exportKek = VaultCryptoManager.deriveKek(exportPassword.toCharArray(), salt, iterations)
        val encryptedPayload = VaultCryptoManager.encrypt(
            payload.toString().toByteArray(Charsets.UTF_8),
            exportKek,
        )

        val container = JSONObject().apply {
            put("format", CONTAINER_FORMAT)
            put("version", 1)
            put("salt", VaultCryptoManager.encodeBase64(salt))
            put("iterations", iterations)
            put("iv", encryptedPayload.ivBase64)
            put("cipherText", encryptedPayload.cipherTextBase64)
        }
        val fileBytes = container.toString().toByteArray(Charsets.UTF_8)
        val fileName = "optisec_vault_${System.currentTimeMillis()}.$FILE_EXTENSION"

        activity.launchCreateDocument(fileName) { uri ->
            if (uri == null) {
                result.error("EXPORT_CANCELLED", "Export was cancelled", null)
                return@launchCreateDocument
            }
            try {
                val stream = activity.contentResolver.openOutputStream(uri)
                    ?: throw IllegalStateException("Could not open output stream")
                stream.use { it.write(fileBytes) }
                result.success(entries.size)
            } catch (e: Exception) {
                result.error("EXPORT_FAILED", e.message, null)
            }
        }
    }

    fun importVault(exportPassword: CharArray, merge: Boolean, dek: SecretKey, result: MethodChannel.Result) {
        activity.launchOpenDocument { uri ->
            if (uri == null) {
                result.error("IMPORT_CANCELLED", "Import was cancelled", null)
                return@launchOpenDocument
            }
            try {
                val bytes = activity.contentResolver.openInputStream(uri)?.use { it.readBytes() }
                    ?: throw IllegalStateException("Could not read the selected file")
                val container = JSONObject(String(bytes, Charsets.UTF_8))
                if (container.optString("format") != CONTAINER_FORMAT) {
                    result.error("INVALID_FILE", "Not a valid OptiSec vault export file", null)
                    return@launchOpenDocument
                }

                val salt = VaultCryptoManager.decodeBase64(container.getString("salt"))
                val iterations = container.getInt("iterations")
                val exportKek = VaultCryptoManager.deriveKek(exportPassword, salt, iterations)
                val blob = VaultCryptoManager.EncryptedBlob(
                    container.getString("iv"),
                    container.getString("cipherText"),
                )

                val payloadBytes = try {
                    VaultCryptoManager.decrypt(blob, exportKek)
                } catch (_: Exception) {
                    result.error("BAD_EXPORT_PASSWORD", "Incorrect export password or corrupted file", null)
                    return@launchOpenDocument
                }

                val payload = JSONObject(String(payloadBytes, Charsets.UTF_8))
                val entriesArray = payload.getJSONArray("entries")

                if (!merge) store.wipeAllEntries()

                for (i in 0 until entriesArray.length()) {
                    val entry = entriesArray.getJSONObject(i)
                    store.upsertEntry(
                        id = null,
                        title = entry.optString("title"),
                        username = entry.optString("username"),
                        url = entry.optString("url"),
                        notes = entry.optString("notes"),
                        password = entry.optString("password"),
                        dek = dek,
                    )
                }

                result.success(entriesArray.length())
            } catch (e: Exception) {
                result.error("IMPORT_FAILED", e.message, null)
            }
        }
    }

    private fun isExportPasswordStrongEnough(password: String): Boolean {
        if (password.length < MIN_EXPORT_PASSWORD_LENGTH) return false
        var classes = 0
        if (password.any { it.isLowerCase() }) classes++
        if (password.any { it.isUpperCase() }) classes++
        if (password.any { it.isDigit() }) classes++
        if (password.any { !it.isLetterOrDigit() }) classes++
        return classes >= 3
    }

    companion object {
        private const val CONTAINER_FORMAT = "opsvault"
        private const val FILE_EXTENSION = "opsvault"
        private const val MIN_EXPORT_PASSWORD_LENGTH = 10
    }
}
