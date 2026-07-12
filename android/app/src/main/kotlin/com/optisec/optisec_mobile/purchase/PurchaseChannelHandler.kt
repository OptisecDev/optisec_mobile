package com.optisec.optisec_mobile.purchase

import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.security.KeyFactory
import java.security.PublicKey
import java.security.Signature
import java.security.spec.X509EncodedKeySpec

/**
 * Verifies Google Play purchase signatures locally using [java.security]
 * (RSA/SHA1, PKCS1) against this app's Play Console license public key —
 * no new Gradle/Dart dependency needed, since `java.security` ships with
 * the platform. See Google's own guidance on local purchase verification:
 * https://developer.android.com/google/play/billing/security#verifying-purchase
 *
 * This is client-side hardening only, not a replacement for server-side
 * receipt validation — see the class-level note in the Dart
 * `PurchaseService`. A device with root/Frida-level compromise can still
 * patch around a local check; a backend verifying purchase tokens against
 * the Play Developer API is the only way to close that gap, and this app
 * has no backend today. That remains a known, accepted limitation.
 */
class PurchaseChannelHandler {

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "verifyPurchaseSignature" -> {
                    val signedData = call.argument<String>("signedData")
                    val signature = call.argument<String>("signature")
                    if (signedData == null || signature == null) {
                        result.error(
                            "INVALID_ARGS",
                            "signedData and signature are required",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    result.success(verify(signedData, signature))
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Returns `true`/`false` for an actual verification result, or `null`
     * if [BASE64_PUBLIC_KEY] hasn't been configured yet — the Dart side
     * treats `null` as "verification unavailable" and falls back to its
     * pre-existing status-only trust rather than rejecting every purchase
     * because of a missing key.
     */
    private fun verify(signedData: String, signature: String): Boolean? {
        if (BASE64_PUBLIC_KEY.isBlank()) return null

        return try {
            val key = generatePublicKey(BASE64_PUBLIC_KEY)
            val sig = Signature.getInstance("SHA1withRSA")
            sig.initVerify(key)
            sig.update(signedData.toByteArray(Charsets.UTF_8))
            sig.verify(Base64.decode(signature, Base64.DEFAULT))
        } catch (_: Exception) {
            // Malformed key/signature/data — treat as failed verification,
            // not as "unconfigured".
            false
        }
    }

    private fun generatePublicKey(base64Key: String): PublicKey {
        val decoded = Base64.decode(base64Key, Base64.DEFAULT)
        val keyFactory = KeyFactory.getInstance("RSA")
        return keyFactory.generatePublic(X509EncodedKeySpec(decoded))
    }

    companion object {
        const val CHANNEL_NAME = "com.optisec.mobile/purchase_verification"

        // TODO: paste this app's Base64-encoded RSA public license key here
        // (Play Console → Monetization setup → Licensing). This value is
        // not secret — it's the *public* half of Google's signing key pair
        // for this app, meant to be embedded client-side — but it is
        // app-specific, so a wrong or placeholder value would make every
        // signature check fail rather than actually verifying anything.
        // Until this is filled in, verify() always returns null and
        // purchases fall back to the pre-existing status-only trust.
        private const val BASE64_PUBLIC_KEY = ""
    }
}
