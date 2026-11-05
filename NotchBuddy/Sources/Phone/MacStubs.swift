import Foundation

// Stand-ins for Mac-only pieces that BholeynathKit's BotEngine calls.
// The Mac app has the real ones (SoundEngine.swift, IslandWindowController.swift).

/// Narayan is silent on the iPhone.
@MainActor
final class SoundEngine {
    static let shared = SoundEngine()
    func play(_ name: String) {}
}

extension Notification.Name {
    static let botDizzy = Notification.Name("notchBuddy.botDizzy")
}
