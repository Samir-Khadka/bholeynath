# Voice assistant — "OK Bholeynath"

Talk to Narayan like a voice assistant: a wake word, a spoken question,
a spoken answer. Voice is a convenience layer over the things the app
already does — it never becomes a second way to approve, send, or run
things.

## What voice can and cannot do

Voice **can**: wake the assistant, ask a question, hear the answer read
back, dictate text into a box, navigate, and summarize what your agents
are doing.

Voice **cannot** (by design, on every platform): approve or deny an agent
permission, send an email or message, run a command, or do anything
destructive. Every approval or send still needs an explicit on-screen
click. If you ask voice to do one of those things, it will say so and
point at the button instead.

Wake-word listening ("Listen for OK Bholeynath") is **opt-in** and shows
a visible mic indicator while it listens. The mic is never open by
stealth.

## How it works, per platform

### Windows (Tauri)

- **Wake word:** "OK Bholeynath", detected by the on-device Parakeet
  model (`windows/src-tauri/src/voice/wake.rs`). The island pill shows
  listening / thinking / speaking states.
- **Speech to text:** Parakeet, on this computer — your voice never
  leaves the computer for transcription.
- **Answers:** Claude, with your own key. The brain's tools are
  deliberately small — pills, music, service info, opening an app,
  preparing (not sending) an email draft, web search. There is no
  approval tool and no send tool.
- **Spoken answers:** the system voice, or ElevenLabs if you add a key.
- **Flow dictation:** the same model powers dictation into any field.
- **Defaults:** voice is ON by default in the hub settings and in the
  backend store — but the Rust side only starts listening once the
  model is downloaded and a Claude key is saved (`voice::sync()` gates
  on `requirements_met()`). A fresh install stays silent, and the hub
  voice page shows a plain-language setup card until both are ready:
  1. download the voice model (about 700 MB, once),
  2. add your Claude key in Notch → Chat,
  3. allow microphone access when your system asks.
- **Privacy copy on the page:** "Your voice never leaves this computer"
  is true here — only the words after the wake word go to Claude for
  the answer.

### Mac (NotchBuddy)

- **Wake word:** "OK Bholeynath" detection plus voice conversation
  states in the island (`NotchBuddy/Sources/App/Voice/`), with
  Parakeet via FluidAudio (models download once from Hugging Face,
  about 650 MB, to Application Support) and Mac dictation with
  on-device recognition where supported.
- **Defaults:** voice command is **off** until you turn it on in
  Settings → Voice, and the toggle stays disabled until microphone and
  speech permissions are granted. Wake-word listening is opt-in, with
  a visible listening state in the island.
- **Answers:** Claude, with your own key, same no-approval rule.

### Android

- **No wake word.** A microphone button sits next to Send in the chat
  composer; it opens the phone's system speech recognizer and drops the
  transcript into the box. You still tap Send — voice never sends.
- **Spoken answers:** a "Read aloud" button under each assistant
  message, spoken by the phone's text-to-speech engine. "Stop" ends it.
- **Privacy, stated on the chat screen:** dictation uses the phone's
  speech recognizer, so the spoken words go to that recognizer service
  to become text — this is **not** the on-device claim the desktop
  makes. Spoken answers are made on the phone. No `RECORD_AUDIO`
  permission is added: the system recognizer owns the microphone.
- **Requirements:** a linked computer with a chat model, as for typed
  chat — voice is a way to fill the box, not a separate chat route.

### iPhone

- **In app:** a microphone button floats above the tab bar and opens
  "Ask Bholeynath": dictate a question, then "Hear the status" speaks
  back what your agents are doing (the same summary Siri's intent
  speaks). Read-only — it never sends an instruction or approves
  anything.
- **Siri / Shortcuts:** "Ask Bholeynath" (`AskBholeynathIntent`) is a
  read-only App Shortcut — "Ask Bholeynath" / "Ask Bholeynath what my
  agents are doing" — returning the agent-status summary as dialog.
  It needs no authentication policy because it sends nothing.
- **Privacy, stated on the sheet:** recognition runs on the iPhone
  when Apple supports it for the language; otherwise the words go to
  Apple to become text. Answers are spoken on the phone.
- **Requirements:** microphone and speech-recognition permission
  (declared in `Info.plist`); a linked Mac for the status itself.

## Setup checklist

| Step | Windows | Mac | Android | iPhone |
| --- | --- | --- | --- | --- |
| Voice model (~650–700 MB, once) | Hub voice page | Settings → Voice | — | — |
| Claude key (for answers) | Notch → Chat | Settings | via the linked computer | via the linked Mac |
| ElevenLabs key (optional, premium voices) | Hub voice page | Settings → Voice | — | — |
| Microphone permission | system prompt | Settings → Voice | system recognizer prompt | system prompt |
| Speech-recognition permission | — | Settings → Voice | — | system prompt |
| Apple Developer setup (Shortcuts distribution) | — | — | — | only for shipping the app; the intent ships with the app target |

Until the model and the key are in place, voice stays silent and the
setup card says what is missing. That is the design, not an error.

## Files

- Windows: `windows/src-tauri/src/voice/` (wake, brain, speech),
  `windows/src-tauri/src/flow/` (dictation + store defaults),
  `windows/src/hub/pages/voice.ts` (setup card),
  `windows/src/hub/voice-setup.ts` (the three setup steps),
  `windows/src/island/voice.ts` (island pill states).
- Mac: `NotchBuddy/Sources/App/Voice/` (engine, wake spotter, brain,
  settings, TTS, captions, transcript history).
- Android: `android/.../ui/VoiceAsk.kt` (dictate button, speaker),
  `android/.../ui/ChatScreen.kt` (wiring), `core/IconSpec.kt` (mic icon).
- iPhone: `NotchBuddy/Sources/Phone/VoiceAskView.swift` (sheet),
  `NotchBuddy/Sources/Phone/HomeView.swift` (mic button),
  `NotchBuddy/Sources/Phone/BholeynathIntents.swift` (Ask Bholeynath).
