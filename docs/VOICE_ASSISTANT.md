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

## Languages: English and Nepali

Voice hears and answers in **English and Nepali**. The answer follows
the language you spoke — ask in Nepali, get a Nepali answer (written in
Devanagari), and the other way round.

| | Hears Nepali | Answers in Nepali | How |
| --- | --- | --- | --- |
| Windows | Yes | Yes | IndicConformer Nepali model, on this computer (see below) |
| Mac | Yes | Yes | Apple Speech `ne-NP`; on-device where Apple supports it, Apple's servers where it does not (Settings says which) |
| Android | Yes, when the phone is in Nepali | Yes, when the message is Nepali | System recognizer (phone language) + phone TTS (message language) |
| iPhone | Yes, pick Nepali next to the mic | Yes, when the text is Nepali | Apple Speech `ne-NP` + on-phone TTS (message language) |

What still only works in English: the wake phrase on Android and
iPhone does not exist (there is no wake word there — both are
push-to-talk), the Siri "Ask Bholeynath" shortcut speaks the English
agent-status summary, and the voice tools (pills, music, email draft,
web search) take commands in either language but the services they
talk to answer in their own language.

## How it works, per platform

### Windows (Tauri)

- **Wake word:** "OK Bholeynath", or "ओके भोलेनाथ" in Nepali, detected
  by the on-device models (`windows/src-tauri/src/voice/wake.rs`). The
  island pill shows listening / thinking / speaking states.
- **Speech to text:** Parakeet for English, AI4Bharat's IndicConformer
  (Nepali, int8, ~198 MB) for Nepali — both on this computer, both
  through sherpa-onnx, both downloaded once at setup and never bundled
  (`windows/src-tauri/src/speech/mod.rs`, model set `INDIC_NEPALI`:
  `parismitaglobalsolutions/indicconformer-sherpa-onnx`,
  `ne/model.int8.onnx` at pinned revision
  `9721eb71eea141fae0982cfcdb9dd2e3d4953c4a`, 197,585,135 bytes,
  SHA-256 `fbbc564e…fb3ccfb56`, plus the shared `tokens.txt`, 67,605
  bytes; the packaging is tagged Apache-2.0, the source model is MIT).
  Your voice never leaves the computer for transcription.
- **Which model hears you:** Settings → Voice → "Voice language".
  "Nepali" hears Nepali only, "English" hears English only (today's
  behaviour, no added latency), "Automatic" (default) hears English
  first and Nepali when the transcript does not read as English — an
  English user pays nothing extra, a Nepali user in Automatic pays one
  second pass. The setting takes effect without restarting the
  listener. Without the Nepali model downloaded, Automatic is Parakeet
  alone.
- **Answers:** Claude, with your own key. The brain's tools are
  deliberately small — pills, music, service info, opening an app,
  preparing (not sending) an email draft, web search. There is no
  approval tool and no send tool. The brain answers in the language
  you spoke.
- **Spoken answers:** the system voice (in the answer's language), or
  ElevenLabs if you add a key — Nepali answers use the `eleven_v3`
  model (`eleven_flash_v2_5` cannot speak Nepali) and prefer a Nepali
  voice from your account when it has one; English keeps the
  low-latency flash model.
- **Flow dictation:** the same models power dictation into any field.
- **Defaults:** voice is ON by default in the hub settings and in the
  backend store — but the Rust side only starts listening once the
  models are downloaded and a Claude key is saved (`voice::sync()` gates
  on `requirements_met()`; Nepali mode also needs the Nepali model).
  A fresh install stays silent, and the hub voice page shows a
  plain-language setup card until both are ready:
  1. download the voice models (about 900 MB, once),
  2. add your Claude key in Notch → Chat,
  3. allow microphone access when your system asks.
- **Privacy copy on the page:** "Your voice never leaves this computer"
  is true here — only the words after the wake word go to Claude for
  the answer.

### Mac (NotchBuddy)

- **Wake word:** "OK Bholeynath" — or "ओके भोलेनाथ" — detection plus
  voice conversation states in the island
  (`NotchBuddy/Sources/App/Voice/`). The voice loop itself runs on
  Apple Speech (`SFSpeechRecognizer`), not on Parakeet: Parakeet via
  FluidAudio (models download once from Hugging Face, about 650 MB, to
  Application Support) powers Flow dictation and the Notetaker only.
- **Speech to text:** Apple Speech in the listen language
  (Settings → Voice → "You speak": Automatic, English, Français,
  नेपाली). Nepali is tried on-device first; where Apple has no
  on-device Nepali model, it falls back to Apple's servers for Nepali
  only, and Settings says so ("Nepali is recognised by Apple on their
  servers on this Mac"). English and French stay on-device. In
  Automatic, a Nepali Mac whose Nepali is server-only still hears
  on-device English — pick Nepali explicitly to hear Nepali there.
- **Answers:** Claude, with your own key, same no-approval rule. The
  answer language follows the language you speak (Settings → Voice,
  or the one-time offer after you speak another language), including
  Nepali; ElevenLabs Nepali answers use `eleven_v3`.
- **Defaults:** voice command is **off** until you turn it on in
  Settings → Voice, and the toggle stays disabled until microphone and
  speech permissions are granted. Wake-word listening is opt-in, with
  a visible listening state in the island.

### Android

- **No wake word.** A microphone button sits next to Send in the chat
  composer; it opens the phone's system speech recognizer and drops the
  transcript into the box. You still tap Send — voice never sends.
  Dictation follows the phone's language: a Nepali phone dictates in
  Nepali.
- **Spoken answers:** a "Read aloud" button under each assistant
  message, spoken by the phone's text-to-speech engine — in the
  message's language, so a Nepali message is read with a Nepali voice
  when the phone has one. "Stop" ends it.
- **Privacy, stated on the chat screen:** dictation uses the phone's
  speech recognizer, so the spoken words go to that recognizer service
  to become text — this is **not** the on-device claim the desktop
  makes. Spoken answers are made on the phone. No `RECORD_AUDIO`
  permission is added: the system recognizer owns the microphone.
- **Requirements:** a linked computer with a chat model, as for typed
  chat — voice is a way to fill the box, not a separate chat route.

### iPhone

- **In app:** a microphone button floats above the tab bar and opens
  "Ask Bholeynath": dictate a question — pick the language next to the
  mic (Nepali is listed wherever Apple ships a `ne-NP` recognizer) —
  then "Hear the status" speaks back what your agents are doing (the
  same summary Siri's intent speaks), in the message's language: a
  Nepali answer is spoken with a Nepali voice, not an English one.
  Read-only — it never sends an instruction or approves anything.
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
| Voice model (once) | Hub voice page, about 900 MB (Parakeet + Nepali + diarizer) | Settings → Voice, Parakeet about 650 MB for dictation; the voice loop itself uses Apple Speech, no download | — | — |
| Claude key (for answers) | Notch → Chat | Settings | via the linked computer | via the linked Mac |
| ElevenLabs key (optional, premium voices) | Hub voice page | Settings → Voice | — | — |
| Microphone permission | system prompt | Settings → Voice | system recognizer prompt | system prompt |
| Speech-recognition permission | — | Settings → Voice | — | system prompt |
| Apple Developer setup (Shortcuts distribution) | — | — | — | only for shipping the app; the intent ships with the app target |

Until the model and the key are in place, voice stays silent and the
setup card says what is missing. That is the design, not an error.

## What CI cannot check here

Rust, Swift and Kotlin do not compile in the sandbox, so CI is the
only build check for: the Nepali recognizer wiring and language
routing (`speech/mod.rs`, `voice/wake.rs`, `voice/mod.rs`), the Mac
voice loop (`VoiceEngine`, `WakeSpotter`, `WakePhrase`,
`ElevenLabsTTS`, the Nepali prompt branches), the iPhone sheet
(`VoiceAskView`, `Dictation.languages`) and the Android speaker
(`VoiceAsk.kt`). On a real machine, also check: a Nepali "ओके
भोलेनाथ" wakes the Windows loop and is answered in Nepali; Automatic
mode still answers an English question with one Parakeet pass; the Mac
shows the server note only when Nepali is server-recognised; the
iPhone offers Nepali in the sheet's language menu only where Apple
ships `ne-NP`.

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
