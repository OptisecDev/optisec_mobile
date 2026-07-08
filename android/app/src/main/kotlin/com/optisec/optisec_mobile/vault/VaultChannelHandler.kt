package com.optisec.optisec_mobile.vault

import com.optisec.optisec_mobile.MainActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Dedicated MethodChannel handler for the `com.optisec.mobile/password_vault`
 * channel, mirroring [com.optisec.optisec_mobile.applock.AppLockChannelHandler].
 * Owns the native Password Vault surface: master-password setup/unlock,
 * biometric enroll/unlock, entry CRUD, auto-lock config, and export/import
 * (delegated to [VaultExportImportManager]).
 *
 * The unwrapped DEK never crosses this channel — every method that needs it
 * pulls it from [VaultStore.getCachedDek] and only ever sends *decrypted
 * results* (entry fields, booleans, counts) back to Dart, never the key
 * itself.
 */
class VaultChannelHandler(private val activity: MainActivity) {

    private val store = VaultStore.getInstance(activity)
    private val biometricManager = VaultBiometricManager()
    private val exportImportManager = VaultExportImportManager(activity, store)

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isVaultInitialized" -> result.success(store.isVaultInitialized())
                    "isUnlocked" -> result.success(store.isUnlocked())

                    "setupVault" -> handleSetupVault(call, result)
                    "unlockWithMasterPassword" -> handleUnlock(call, result)
                    "lockVault" -> {
                        store.lockSession()
                        result.success(null)
                    }

                    "canUseBiometric" -> result.success(biometricManager.canUseBiometric(activity))
                    "isBiometricEnabled" -> result.success(store.isBiometricEnabled())
                    "enrollBiometric" -> handleEnrollBiometric(result)
                    "unlockWithBiometric" -> handleBiometricUnlock(result)
                    "disableBiometric" -> {
                        biometricManager.deleteKey()
                        store.clearBiometricWrappedDek()
                        result.success(null)
                    }

                    "getAutoLockTimeoutMillis" -> result.success(store.getAutoLockTimeoutMillis())
                    "setAutoLockTimeoutMillis" -> {
                        val millis = (call.argument<Number>("millis"))?.toLong()
                        if (millis == null) {
                            result.error("INVALID_ARGUMENT", "millis is required", null)
                            return@setMethodCallHandler
                        }
                        store.setAutoLockTimeoutMillis(millis)
                        result.success(null)
                    }

                    "listEntries" -> withUnlockedDek(result) { dek ->
                        result.success(store.listEntryMetadata(dek))
                    }
                    "entryCount" -> result.success(store.entryCount())
                    "getEntryPassword" -> withUnlockedDek(result) { dek ->
                        val id = call.argument<String>("id")
                        if (id.isNullOrEmpty()) {
                            result.error("INVALID_ARGUMENT", "id is required", null)
                            return@withUnlockedDek
                        }
                        val password = store.getEntryPassword(id, dek)
                        if (password == null) {
                            result.error("NOT_FOUND", "Entry not found", null)
                        } else {
                            result.success(password)
                        }
                    }
                    "upsertEntry" -> withUnlockedDek(result) { dek ->
                        val id = store.upsertEntry(
                            id = call.argument<String>("id"),
                            title = call.argument<String>("title") ?: "",
                            username = call.argument<String>("username") ?: "",
                            url = call.argument<String>("url") ?: "",
                            notes = call.argument<String>("notes") ?: "",
                            password = call.argument<String>("password") ?: "",
                            dek = dek,
                        )
                        result.success(id)
                    }
                    "deleteEntry" -> withUnlockedDek(result) { _ ->
                        val id = call.argument<String>("id")
                        if (id.isNullOrEmpty()) {
                            result.error("INVALID_ARGUMENT", "id is required", null)
                            return@withUnlockedDek
                        }
                        store.deleteEntry(id)
                        result.success(null)
                    }

                    "exportVault" -> {
                        val masterPassword = call.argument<String>("masterPassword")
                        val exportPassword = call.argument<String>("exportPassword")
                        if (masterPassword.isNullOrEmpty() || exportPassword.isNullOrEmpty()) {
                            result.error("INVALID_ARGUMENT", "masterPassword and exportPassword are required", null)
                            return@setMethodCallHandler
                        }
                        exportImportManager.exportVault(masterPassword.toCharArray(), exportPassword, result)
                    }
                    "importVault" -> {
                        val exportPassword = call.argument<String>("exportPassword")
                        val merge = call.argument<Boolean>("merge") ?: true
                        if (exportPassword.isNullOrEmpty()) {
                            result.error("INVALID_ARGUMENT", "exportPassword is required", null)
                            return@setMethodCallHandler
                        }
                        withUnlockedDek(result) { dek ->
                            exportImportManager.importVault(exportPassword.toCharArray(), merge, dek, result)
                        }
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("VAULT_ERROR", e.message, null)
            }
        }
    }

    private inline fun withUnlockedDek(result: MethodChannel.Result, block: (javax.crypto.SecretKey) -> Unit) {
        val dek = store.getCachedDek()
        if (dek == null) {
            result.error("NOT_UNLOCKED", "Vault is locked", null)
            return
        }
        block(dek)
    }

    private fun handleSetupVault(call: MethodCall, result: MethodChannel.Result) {
        if (store.isVaultInitialized()) {
            result.error("ALREADY_INITIALIZED", "Vault already set up", null)
            return
        }
        val masterPassword = call.argument<String>("masterPassword")
        if (masterPassword.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "masterPassword is required", null)
            return
        }
        store.setupVault(masterPassword.toCharArray())
        result.success(null)
    }

    private fun handleUnlock(call: MethodCall, result: MethodChannel.Result) {
        val masterPassword = call.argument<String>("masterPassword")
        if (masterPassword.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "masterPassword is required", null)
            return
        }
        val remaining = store.getLockoutRemainingMillis()
        if (remaining > 0) {
            result.error("LOCKED_OUT", "Too many failed attempts", remaining)
            return
        }
        val dek = store.unlockWithMasterPassword(masterPassword.toCharArray())
        result.success(dek != null)
    }

    private fun handleEnrollBiometric(result: MethodChannel.Result) {
        val dek = store.getCachedDek()
        if (dek == null) {
            result.error("NOT_UNLOCKED", "Vault must be unlocked with the master password first", null)
            return
        }
        biometricManager.enroll(
            activity,
            dek,
            onSuccess = { blob ->
                store.setBiometricWrappedDek(blob)
                result.success(true)
            },
            onError = { message -> result.error("BIOMETRIC_ERROR", message, null) },
        )
    }

    private fun handleBiometricUnlock(result: MethodChannel.Result) {
        val wrapped = store.getBiometricWrappedDek()
        if (wrapped == null || !store.isBiometricEnabled()) {
            result.error("BIOMETRIC_NOT_ENABLED", "Biometric unlock is not enabled", null)
            return
        }
        val remaining = store.getLockoutRemainingMillis()
        if (remaining > 0) {
            result.error("LOCKED_OUT", "Too many failed attempts", remaining)
            return
        }
        biometricManager.unlock(
            activity,
            wrapped,
            onSuccess = { dek ->
                store.cacheDek(dek)
                store.resetFailedAttempts()
                result.success(true)
            },
            onError = { message -> result.error("BIOMETRIC_ERROR", message, null) },
            onKeyInvalidated = {
                store.clearBiometricWrappedDek()
                result.error(
                    "BIOMETRIC_KEY_INVALIDATED",
                    "Biometric enrollment changed on this device; re-enable biometric unlock",
                    null,
                )
            },
        )
    }

    companion object {
        const val CHANNEL_NAME = "com.optisec.mobile/password_vault"
    }
}
