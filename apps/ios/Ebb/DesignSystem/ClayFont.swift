import SwiftUI

/// App typeface: Grandstander, a chunky, neat, hand-lettered font (OFL, bundled in Resources/Fonts) for the play-dough feel.
/// Mirrors the system text styles so `.font(ClayFont.headline)` reads like `.font(.headline)` and still scales with
/// Dynamic Type. It runs wide, so sizes sit a touch under the system defaults.
enum ClayFont {
    static let largeTitle = style(32, .largeTitle, "Black")
    static let title = style(27, .title, "Black")
    static let title2 = style(21, .title2, "ExtraBold")
    static let title3 = style(19, .title3, "ExtraBold")
    static let headline = style(16, .headline, "ExtraBold")
    static let body = style(16, .body, "SemiBold")
    static let subheadline = style(14, .subheadline, "SemiBold")
    static let footnote = style(13, .footnote, "SemiBold")
    static let caption = style(12, .caption, "SemiBold")

    /// Fixed-size text (screen titles, icons). Heavy weights use Black, the chunkiest face.
    static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design? = nil) -> Font {
        .custom(weight == .heavy || weight == .black ? "Grandstander-Black" : "Grandstander-ExtraBold", size: size)
    }

    private static func style(_ size: CGFloat, _ relative: Font.TextStyle, _ face: String) -> Font {
        .custom("Grandstander-\(face)", size: size, relativeTo: relative)
    }
}
