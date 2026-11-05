import SwiftUI
import AVFoundation

/// Spoken agent status on the iPhone: ask about your agents out loud, hear
/// the answer. Read-only on purpose: it never sends an instruction and never
/// approves anything — those still need an explicit tap on a card, or Face ID
/// on the decision itself.
///
/// Privacy, stated on screen: recognition prefers the iPhone itself where
/// Apple supports it (see Dictation), otherwise the words go to Apple to
/// become text. Answers are spoken on this phone.
struct VoiceAskView: View {
    let link: PhoneLink
    @Environment(\.dismiss) private var dismiss
    @State private var dictation = Dictation()
    @State private var answer: String?
    @State private var busy = false
    @State private var speaker = AVSpeechSynthesizer()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ask about your agents")
                    .font(.title2.bold())
                Text("Tap the microphone, ask what your agents are doing, then hear the status spoken back — in English or Nepali.")
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button {
                        Task { await dictation.toggle(startingFrom: "") }
                    } label: {
                        Label(dictation.isRecording ? "Listening…" : "Tap to speak",
                              systemImage: dictation.isRecording ? "mic.fill" : "mic")
                    }
                    .buttonStyle(.borderedProminent)
                    Menu {
                        Picker("Dictation language", selection: $dictation.localeID) {
                            ForEach(Dictation.languages, id: \.self) { id in
                                Text(Locale.current.localizedString(forIdentifier: id) ?? id).tag(id)
                            }
                        }
                    } label: {
                        Text(Dictation.shortName(dictation.localeID))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.secondary.opacity(0.15), in: Capsule())
                    }
                    .accessibilityLabel("Dictation language")
                }
                if !dictation.transcript.isEmpty {
                    Text("You said: \(dictation.transcript)")
                }
                Button("Hear the status") {
                    Task { await ask() }
                }
                .buttonStyle(.bordered)
                .disabled(busy)
                if let answer {
                    Text(answer)
                    Button("Stop speaking") { speaker.stopSpeaking(at: .immediate) }
                }
                Text("Speech recognition runs on your iPhone when it supports it; otherwise your words go to Apple to become text. Answers are spoken on this phone. Voice never sends an instruction or approves anything here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Ask Bholeynath")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onDisappear {
                speaker.stopSpeaking(at: .immediate)
                Task { await dictation.stop() }
            }
        }
    }

    /// The same status summary Siri's agent-status intent speaks: refresh,
    /// most urgent session first, spoken back. Nothing is sent anywhere.
    private func ask() async {
        busy = true
        defer { busy = false }
        await link.refresh()
        let sessions = link.sessions.sortedByUrgency()
        guard let lead = sessions.first else {
            let text = "All quiet: no agent session on your Mac."
            answer = text
            speak(text)
            return
        }
        let summary = sessions.summary ?? "All quiet"
        let text = "\(summary). \(lead.pillName), \(lead.title): \(lead.statusText)."
        answer = text
        speak(text)
    }

    private func speak(_ text: String) {
        speaker.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage(for: text))
        speaker.speak(utterance)
    }

    /// Nepali when the text is Devanagari, else the language the question
    /// was dictated in (the sheet's picker, remembered), else the iPhone's
    /// language. Never a hard-coded "en-US": a Nepali answer was read in an
    /// English voice before this.
    private func voiceLanguage(for text: String) -> String {
        if text.unicodeScalars.contains(where: { (0x0900...0x097F).contains($0.value) }) {
            return "ne-NP"
        }
        return dictation.localeID
    }
}
