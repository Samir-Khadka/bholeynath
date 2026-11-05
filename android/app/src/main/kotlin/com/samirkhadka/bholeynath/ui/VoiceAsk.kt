package com.samirkhadka.bholeynath.ui

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.samirkhadka.bholeynath.R
import com.samirkhadka.bholeynath.core.IconKind

/**
 * Voice on Android: dictation into the chat box, and answers read aloud.
 *
 * Privacy, stated honestly in the chat screen: dictation uses the phone's
 * system speech recognizer (RecognizerIntent), so the spoken words go to
 * that recognizer service to become text — unlike the desktop, where the
 * Parakeet model runs on the computer. Spoken answers are made on this
 * phone by its text-to-speech engine. Nothing here approves anything or
 * sends anything: dictation only fills the box, and the user still taps
 * Send; the read-aloud button only speaks text already on screen.
 */

/** A microphone button in the composer's style: speaks into the box, never sends. */
@Composable
fun VoiceDictateButton(onTranscript: (String) -> Unit, enabled: Boolean) {
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val spoken = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
            if (!spoken.isNullOrBlank()) onTranscript(spoken)
        }
    }
    val label = stringResource(R.string.voice_dictate)
    Box(
        Modifier.alpha(if (enabled) 1f else 0.4f).size(56.dp).clip(CircleShape).background(tokens().panel2.c())
            .clickable(enabled = enabled, role = Role.Button) {
                launcher.launch(
                    Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                        putExtra(RecognizerIntent.EXTRA_PROMPT, label)
                    },
                )
            }
            .semantics { contentDescription = label },
        contentAlignment = Alignment.Center,
    ) { BholeynathIcon(IconKind.MIC, tint = tokens().text.c(), size = 22.dp) }
}

/** The phone's text-to-speech engine, kept for one screen and shut down with it. */
class VoiceSpeaker(appContext: Context) {
    private var ready = false
    private var pending: String? = null
    private val tts = TextToSpeech(appContext) { status ->
        if (status == TextToSpeech.SUCCESS) {
            ready = true
            pending?.let { speakNow(it) }
            pending = null
        }
    }

    fun speak(text: String) {
        if (ready) speakNow(text) else pending = text
    }

    private fun speakNow(text: String) {
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "bholeynath")
    }

    fun stop() {
        tts.stop()
    }

    fun shutdown() {
        tts.stop()
        tts.shutdown()
    }
}

@Composable
fun rememberVoiceSpeaker(): VoiceSpeaker {
    val context = LocalContext.current
    val speaker = remember { VoiceSpeaker(context.applicationContext) }
    DisposableEffect(Unit) { onDispose { speaker.shutdown() } }
    return speaker
}
