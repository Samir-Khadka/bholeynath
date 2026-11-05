import Foundation

// MARK: - WakePhrase tests (pure functions, no concurrency)

@main
enum WakePhraseTests {

    static var failures = 0

    static func main() {
        // MARK: split — should match

        // Basic wake phrases (no command)
        checkMatch("ok bholeynath",              WakePhrase.split("ok bholeynath"),              cmd: "")
        checkMatch("OK BHOLEYNATH",              WakePhrase.split("OK BHOLEYNATH"),              cmd: "")
        checkMatch("okay bholeynath",            WakePhrase.split("okay bholeynath"),            cmd: "")
        checkMatch("ok kuku",                WakePhrase.split("ok kuku"),                cmd: "")
        checkMatch("ok cou cou",             WakePhrase.split("ok cou cou"),             cmd: "")
        checkMatch("hey bholeynath",             WakePhrase.split("hey bholeynath"),             cmd: "")
        checkMatch("Hey Bholeynath",             WakePhrase.split("Hey Bholeynath"),             cmd: "")

        // Command extracted from original text (casing/punctuation preserved)
        checkMatch("Okay, Bholeynath, ajoute GitHub",
                   WakePhrase.split("Okay, Bholeynath, ajoute GitHub"),             cmd: "ajoute GitHub")
        checkMatch("ok cuckoo add github",
                   WakePhrase.split("ok cuckoo add github"),                    cmd: "add github")
        checkMatch("ok bholeynath ouvre figma",
                   WakePhrase.split("ok bholeynath ouvre figma"),                   cmd: "ouvre figma")

        // Apostrophes, hyphens and accents preserved in command
        checkMatch("OK Bholeynath, mets l'album de Daft Punk",
                   WakePhrase.split("OK Bholeynath, mets l'album de Daft Punk"),   cmd: "mets l'album de Daft Punk")
        checkMatch("ok bholeynath qu'est-ce que fait Claude ?",
                   WakePhrase.split("ok bholeynath qu'est-ce que fait Claude ?"),  cmd: "qu'est-ce que fait Claude ?")

        // Wake anywhere in transcript (word-boundary search)
        checkMatch("euh ok bholeynath mets de la musique",
                   WakePhrase.split("euh ok bholeynath mets de la musique"),        cmd: "mets de la musique")
        checkMatch("la chanson dit ok bholeynath",
                   WakePhrase.split("la chanson dit ok bholeynath"),                cmd: "") // accepted false positive

        // LAST occurrence wins
        checkMatch("ok bholeynath search ok bholeynath play music",
                   WakePhrase.split("ok bholeynath search ok bholeynath play music"),   cmd: "play music")

        // Partial word-by-word delivery
        checkNoMatch("ok alone",             WakePhrase.split("ok"))
        checkMatch("ok bholeynath partial",      WakePhrase.split("ok bholeynath"),              cmd: "")
        checkMatch("ok bholeynath with more",    WakePhrase.split("ok bholeynath mets"),         cmd: "mets")

        // MARK: split — should NOT match
        checkNoMatch("standalone bholeynath",    WakePhrase.split("bholeynath"))
        checkNoMatch("standalone BHOLEYNATH",    WakePhrase.split("BHOLEYNATH"))
        checkNoMatch("partial bholeynath ça va", WakePhrase.split("bholeynath ça va"))
        checkNoMatch("bholeynath comment",       WakePhrase.split("bholeynath comment tu vas"))
        checkNoMatch("ok google",            WakePhrase.split("ok google"))
        checkNoMatch("hey siri",             WakePhrase.split("hey siri"))
        checkNoMatch("okkkk bholeynath",         WakePhrase.split("okkkk bholeynath"))
        checkNoMatch("empty",                WakePhrase.split(""))

        // Summary
        if failures == 0 { print("\n\(total)/\(total) tests passed.") }
        else { print("\n\(failures) test(s) FAILED."); exit(1) }
    }

    static var total = 0

    static func checkMatch(_ label: String, _ r: WakePhrase.SplitResult, cmd: String) {
        total += 1
        if !r.matched {
            print("✗  \(label) — expected match, got no match"); failures += 1; return
        }
        if r.command != cmd {
            print("✗  \(label) — matched ✓ but command \"\(r.command)\" ≠ \"\(cmd)\""); failures += 1; return
        }
        print("✓  \(label)")
    }

    static func checkNoMatch(_ label: String, _ r: WakePhrase.SplitResult) {
        total += 1
        if r.matched { print("✗  \(label) — expected no match, got matched (cmd: \"\(r.command)\")"); failures += 1 }
        else         { print("✓  \(label)") }
    }
}
