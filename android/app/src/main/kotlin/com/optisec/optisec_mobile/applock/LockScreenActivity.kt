package com.optisec.optisec_mobile.applock

import android.graphics.drawable.Drawable
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.os.Looper
import android.widget.ImageView
import android.widget.TextView
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.optisec.optisec_mobile.R
import java.util.concurrent.Executors

/**
 * The real authentication gate for a locked app: tries BiometricPrompt
 * first (fingerprint/face), with a "Use PIN" negative button that falls
 * back to the native numeric pad backed by [AppLockStore.verifyPin].
 * Declared singleInstance + excludeFromRecents in the manifest so it can't
 * be duplicated or screenshotted into the recents list.
 */
class LockScreenActivity : FragmentActivity() {

    private lateinit var store: AppLockStore
    private lateinit var targetPackage: String

    private lateinit var appIconImageView: ImageView
    private lateinit var appNameText: TextView
    private lateinit var statusText: TextView
    private lateinit var pinDots: List<TextView>
    private lateinit var pinKeys: Map<TextView, Char>
    private lateinit var backspaceKey: TextView
    private lateinit var retryBiometricKey: TextView

    private val enteredPin = StringBuilder()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val verifyExecutor = Executors.newSingleThreadExecutor()
    private var countDownTimer: CountDownTimer? = null
    private var pinLocked = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setTheme(R.style.LockScreenTheme)
        setContentView(R.layout.activity_lock_screen)

        val pkg = intent?.getStringExtra(EXTRA_TARGET_PACKAGE)
        store = AppLockStore.getInstance(this)

        if (pkg == null || !store.isPinSet()) {
            finish()
            return
        }
        targetPackage = pkg

        bindViews()
        loadTargetAppInfo()
        setupPinPad()

        if (store.getLockoutRemainingMillis() > 0) {
            showPinPad(locked = true)
        } else if (canUseBiometric()) {
            showBiometricPrompt()
        } else {
            showPinPad(locked = false)
        }
    }

    override fun onBackPressed() {
        // Never fall through to whatever was behind us — leave the curtain
        // up over the locked app and go to the home screen instead.
        LockOverlayManager.getInstance(this).hide()
        moveTaskToBack(true)
    }

    override fun onDestroy() {
        countDownTimer?.cancel()
        verifyExecutor.shutdownNow()
        super.onDestroy()
    }

    private fun bindViews() {
        appIconImageView = findViewById(R.id.appIconImageView)
        appNameText = findViewById(R.id.appNameText)
        statusText = findViewById(R.id.statusText)
        pinDots = listOf(
            findViewById(R.id.pinDot1),
            findViewById(R.id.pinDot2),
            findViewById(R.id.pinDot3),
            findViewById(R.id.pinDot4),
        )
        pinKeys = mapOf(
            findViewById<TextView>(R.id.btn0) to '0',
            findViewById<TextView>(R.id.btn1) to '1',
            findViewById<TextView>(R.id.btn2) to '2',
            findViewById<TextView>(R.id.btn3) to '3',
            findViewById<TextView>(R.id.btn4) to '4',
            findViewById<TextView>(R.id.btn5) to '5',
            findViewById<TextView>(R.id.btn6) to '6',
            findViewById<TextView>(R.id.btn7) to '7',
            findViewById<TextView>(R.id.btn8) to '8',
            findViewById<TextView>(R.id.btn9) to '9',
        )
        backspaceKey = findViewById(R.id.btnBackspace)
        retryBiometricKey = findViewById(R.id.btnRetryBiometric)
    }

    private fun loadTargetAppInfo() {
        val pm = packageManager
        val label: CharSequence
        val icon: Drawable?
        try {
            val appInfo = pm.getApplicationInfo(targetPackage, 0)
            label = pm.getApplicationLabel(appInfo)
            icon = pm.getApplicationIcon(appInfo)
        } catch (_: Exception) {
            appNameText.text = targetPackage
            appIconImageView.setImageDrawable(null)
            return
        }
        appNameText.text = label
        appIconImageView.setImageDrawable(icon)
    }

    private fun setupPinPad() {
        for ((view, digit) in pinKeys) {
            view.setOnClickListener { onDigitEntered(digit) }
        }
        backspaceKey.setOnClickListener { onBackspace() }
        retryBiometricKey.setOnClickListener {
            if (canUseBiometric()) showBiometricPrompt()
        }
    }

    // ── Biometric ────────────────────────────────────────────────────
    private fun canUseBiometric(): Boolean {
        val manager = BiometricManager.from(this)
        val result = manager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.BIOMETRIC_WEAK,
        )
        return result == BiometricManager.BIOMETRIC_SUCCESS
    }

    private fun showBiometricPrompt() {
        val executor = ContextCompat.getMainExecutor(this)
        val prompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    result: BiometricPrompt.AuthenticationResult,
                ) {
                    onUnlocked()
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    // Negative button ("Use PIN"), user cancel, timeout, or biometric
                    // lockout — all fall back to the PIN pad, which is already visible.
                    showPinPad(locked = store.getLockoutRemainingMillis() > 0)
                }

                override fun onAuthenticationFailed() {
                    // Wrong fingerprint/face; the system dialog stays open and lets
                    // the user retry on its own, nothing to do here.
                }
            },
        )

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(getString(R.string.app_lock_biometric_title, appNameText.text))
            .setSubtitle(getString(R.string.app_lock_biometric_subtitle))
            .setNegativeButtonText(getString(R.string.app_lock_biometric_negative_button))
            .setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                    BiometricManager.Authenticators.BIOMETRIC_WEAK,
            )
            .build()

        prompt.authenticate(promptInfo)
    }

    // ── PIN pad ──────────────────────────────────────────────────────
    private fun showPinPad(locked: Boolean) {
        pinLocked = locked
        if (locked) {
            startLockoutCountdown()
        } else {
            statusText.text = getString(R.string.app_lock_enter_pin_prompt)
        }
    }

    private fun onDigitEntered(digit: Char) {
        if (pinLocked || enteredPin.length >= PIN_LENGTH) return
        enteredPin.append(digit)
        updateDots()
        if (enteredPin.length == PIN_LENGTH) {
            verifyEnteredPin()
        }
    }

    private fun onBackspace() {
        if (pinLocked || enteredPin.isEmpty()) return
        enteredPin.deleteCharAt(enteredPin.length - 1)
        updateDots()
    }

    private fun updateDots(errorFlash: Boolean = false) {
        val fillRes = if (errorFlash) {
            R.drawable.app_lock_pin_dot_error
        } else {
            R.drawable.app_lock_pin_dot_filled
        }
        for (i in pinDots.indices) {
            pinDots[i].setBackgroundResource(
                if (i < enteredPin.length) fillRes else R.drawable.app_lock_pin_dot_empty,
            )
        }
    }

    private fun verifyEnteredPin() {
        val pin = enteredPin.toString()
        verifyExecutor.execute {
            val success = store.verifyPin(pin)
            mainHandler.post { onPinVerified(success) }
        }
    }

    private fun onPinVerified(success: Boolean) {
        if (success) {
            onUnlocked()
            return
        }

        updateDots(errorFlash = true)
        mainHandler.postDelayed({
            enteredPin.clear()
            updateDots()
            val remaining = store.getLockoutRemainingMillis()
            if (remaining > 0) {
                showPinPad(locked = true)
            } else {
                statusText.text = getString(R.string.app_lock_wrong_pin)
            }
        }, 350)
    }

    private fun startLockoutCountdown() {
        countDownTimer?.cancel()
        val remaining = store.getLockoutRemainingMillis()
        if (remaining <= 0) {
            pinLocked = false
            statusText.text = getString(R.string.app_lock_enter_pin_prompt)
            return
        }
        countDownTimer = object : CountDownTimer(remaining, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                statusText.text = getString(
                    R.string.app_lock_locked_out,
                    formatRemaining(millisUntilFinished),
                )
            }

            override fun onFinish() {
                pinLocked = false
                statusText.text = getString(R.string.app_lock_enter_pin_prompt)
            }
        }.start()
    }

    private fun formatRemaining(millis: Long): String {
        val totalSeconds = (millis / 1000).coerceAtLeast(1)
        return if (totalSeconds < 60) {
            getString(R.string.app_lock_seconds_short, totalSeconds.toInt())
        } else {
            getString(R.string.app_lock_minutes_short, (totalSeconds / 60).toInt() + 1)
        }
    }

    private fun onUnlocked() {
        countDownTimer?.cancel()
        AppLockMonitorService.markUnlocked(targetPackage)
        LockOverlayManager.getInstance(this).hide()
        finish()
    }

    companion object {
        const val EXTRA_TARGET_PACKAGE = "target_package"
        private const val PIN_LENGTH = 4
    }
}
