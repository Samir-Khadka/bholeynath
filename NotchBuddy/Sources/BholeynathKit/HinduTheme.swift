import SwiftUI

/// The Hindu theme palette, shared by the Mac and iPhone targets.
///
/// Saffron, gold, deep indigo, maroon and ivory parchment — the same tokens
/// as the Windows frontend's theme.css. Display colours only: Narayan's own
/// state colours (PillColors, WidgetTone) are untouched, and no deity image
/// is ever used as the companion — deity art is framed display art (see
/// AboutView's Blessing section on iPhone).
enum HinduTheme {
    static let saffron = Color(hex: "#FF9933")
    static let gold = Color(hex: "#D4AF37")
    static let indigo = Color(hex: "#1A1446")
    static let maroon = Color(hex: "#800000")
    static let parchment = Color(hex: "#FFF8E7")

    /// Gold frame for blessing art.
    static let blessingBorder = gold
}
