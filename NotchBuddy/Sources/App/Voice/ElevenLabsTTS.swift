#if !APPSTORE
import Foundation

// MARK: - ElevenLabsTTS
//
// Optional voice for Bholeynath's answers (Settings → Voice → ElevenLabs), with the user's
// own API key stored in the Keychain ("elevenlabs-api-key"). Network only to
// api.elevenlabs.io, only while Bholeynath speaks.
//
// No voice ID is hard-coded: ElevenLabs' old default voices expire on 31 Dec 2026 and
// newer accounts don't have them. Bholeynath lists the voices of the user's account and
// picks the first one of the chosen gender in the answer language (a Nepali one for a
// Nepali answer when the account has one), then caches it. Nepali answers use the
// `eleven_v3` model — `eleven_flash_v2_5` cannot speak Nepali; English keeps the
// low-latency flash model.

@MainActor
final class ElevenLabsTTS {
    static let shared = ElevenLabsTTS()

    static let keyName = "elevenlabs-api-key"
    /// `eleven_v3` speaks Nepali; the flash model does not. English keeps flash.
    private static func model(forAnswerLanguage lang: String) -> String {
        lang == "ne" ? "eleven_v3" : "eleven_flash_v2_5"
    }

    static var isActive: Bool {
        VoiceSettings.ttsEngine == "elevenlabs" && KeychainStore.shared.get(keyName) != nil
    }

    struct Voice: Equatable { let id: String; let name: String }
    private var chosen: (gender: String, language: String, voice: Voice)?

    /// Name of the voice in use, for Settings ("Rachel", "Talia – Warm Soft Guide"…).
    var currentVoiceName: String? { chosen?.voice.name }

    /// Forget the cached voice (gender, answer language or key changed).
    func reset() { chosen = nil }

    /// MP3 for one sentence, or nil (no key, network error, quota…) → Mac voice instead.
    func audio(for text: String) async -> Data? {
        guard let key = KeychainStore.shared.get(Self.keyName),
              let voice = await voice(key: key) else { return nil }
        var comps = URLComponents(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voice.id)")!
        comps.queryItems = [URLQueryItem(name: "output_format", value: "mp3_44100_128")]
        guard let url = comps.url else { return nil }
        var req = URLRequest(url: url, timeoutInterval: 8)
        req.httpMethod = "POST"
        req.setValue(key, forHTTPHeaderField: "xi-api-key")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["text": text, "model_id": Self.model(forAnswerLanguage: VoiceSettings.language)])
        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              (resp as? HTTPURLResponse)?.statusCode == 200, !data.isEmpty else {
            appendAppLog("nb.log", "[Voice] ElevenLabs request failed, Mac voice used")
            return nil
        }
        return data
    }

    /// The voice for the chosen gender, looked up once in the user's account.
    func voice(key: String) async -> Voice? {
        let gender = VoiceSettings.elevenGender
        let language = VoiceSettings.language
        if let c = chosen, c.gender == gender, c.language == language { return c.voice }
        var req = URLRequest(url: URL(string: "https://api.elevenlabs.io/v1/voices")!, timeoutInterval: 8)
        req.setValue(key, forHTTPHeaderField: "xi-api-key")
        guard let (data, resp) = try? await URLSession.shared.data(for: req),
              (resp as? HTTPURLResponse)?.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let voices = json["voices"] as? [[String: Any]] else {
            appendAppLog("nb.log", "[Voice] ElevenLabs voice list unavailable")
            return nil
        }
        guard let v = Self.pick(voices, gender: gender, language: language) else { return nil }
        chosen = (gender, language, v)
        return v
    }

    /// First voice of the gender in the answer language (a Nepali one for a
    /// Nepali answer — `eleven_v3` still speaks Nepali with an English voice,
    /// just with an accent; a young one first for a man); else any voice of
    /// the gender; else the first one.
    nonisolated static func pick(_ voices: [[String: Any]], gender: String, language: String = "en") -> Voice? {
        func labels(_ v: [String: Any]) -> [String: String] { v["labels"] as? [String: String] ?? [:] }
        func isEnglish(_ v: [String: Any]) -> Bool {
            let l = labels(v)
            if let lang = l["language"] { return lang.lowercased().hasPrefix("en") }
            let accent = (l["accent"] ?? "").lowercased()
            return accent.isEmpty || ["american", "british", "australian", "irish", "english", "us", "uk"]
                .contains { accent.contains($0) }
        }
        func isNepali(_ v: [String: Any]) -> Bool {
            (labels(v)["language"] ?? "").lowercased().hasPrefix("ne")
        }
        func isYoung(_ v: [String: Any]) -> Bool { (labels(v)["age"] ?? "").lowercased().contains("young") }
        let ofGender = voices.filter { labels($0)["gender"]?.lowercased() == gender }
        let inLanguage = ofGender.filter { language == "ne" ? isNepali($0) : isEnglish($0) }
        // Male: a young voice first, it sounds closer to Bholeynath than a deep narrator.
        let young = gender == "male" ? inLanguage.first(where: isYoung) : nil
        let v = young ?? inLanguage.first ?? ofGender.first ?? voices.first
        guard let v, let id = v["voice_id"] as? String else { return nil }
        return Voice(id: id, name: v["name"] as? String ?? id)
    }
}
#endif
