import SwiftUI

/// Shared colors, gradients and radii. Change the look here, not in individual views.
/// Style: claymation landscape (inspired by clay.com, see .claude/resources/references/design-references/clay):
/// grainy sky and hills, clean white panels, crisp ink type, colorful clay icons in pale tiles.
enum Theme {
    // Surfaces (dark mode: warm night instead of black)
    static let canvas = dynamic(light: (0.98, 0.98, 0.96), dark: (0.11, 0.12, 0.13))
    static let surface = dynamic(light: (1.00, 1.00, 1.00), dark: (0.18, 0.19, 0.20))
    static let tile = dynamic(light: (0.94, 0.93, 0.91), dark: (0.25, 0.26, 0.27))

    // Landscape (dark mode: a moonlit night scene)
    static let skyTop = dynamic(light: (0.47, 0.76, 0.89), dark: (0.09, 0.11, 0.27))
    static let skyBottom = dynamic(light: (0.70, 0.88, 0.93), dark: (0.27, 0.25, 0.47))
    static let hillFar = dynamic(light: (0.36, 0.62, 0.55), dark: (0.17, 0.27, 0.36))
    static let hillNear = dynamic(light: (0.27, 0.55, 0.33), dark: (0.11, 0.22, 0.24))
    static let tree = dynamic(light: (0.24, 0.52, 0.48), dark: (0.12, 0.26, 0.30))
    static let hillMeadow = dynamic(light: (0.50, 0.72, 0.45), dark: (0.15, 0.31, 0.29))
    static let sun = Color(red: 1.00, green: 0.84, blue: 0.40)
    static let moon = Color(red: 0.98, green: 0.95, blue: 0.84)
    static let firefly = Color(red: 0.95, green: 1.00, blue: 0.55)

    // Clay colors
    static let clayTeal = Color(red: 0.23, green: 0.62, blue: 0.58)
    static let clayBlue = Color(red: 0.29, green: 0.56, blue: 0.85)
    static let clayOrange = Color(red: 0.91, green: 0.50, blue: 0.22)
    static let clayButter = Color(red: 0.98, green: 0.80, blue: 0.36)
    static let clayPink = Color(red: 0.93, green: 0.45, blue: 0.62)
    static let clayLavender = Color(red: 0.55, green: 0.47, blue: 0.86)   // panic: calm, never red

    /// Panic / guided color: sea-glass blue by day (fits the sky and hills), lavender at night. Never red.
    static let claySea = dynamic(light: (0.31, 0.61, 0.79), dark: (0.55, 0.47, 0.86))

    /// Solid clay colors the option tiles cycle through, one set per page (white text stays readable on all of them).
    static let quickPalette = [clayTeal, clayOrange, clayBlue, clayPink]
    static let guidedPalette = [claySea, Color(red: 0.84, green: 0.58, blue: 0.14), Color(red: 0.36, green: 0.65, blue: 0.40), clayPink]   // not lavender: claySea is lavender in dark mode

    static let accent = clayTeal
    static let calmGradient = LinearGradient(colors: [skyTop, clayTeal], startPoint: .top, endPoint: .bottom)
    static let panicGradient = LinearGradient(colors: [claySea, clayBlue], startPoint: .top, endPoint: .bottom)

    static let cardRadius: CGFloat = 24
    static let heroRadius: CGFloat = 32
    static let tileRadius: CGFloat = 14

    /// Two-tone clay colors for an icon tile. Stable per symbol so each item keeps its colors.
    static func iconColors(for symbol: String) -> (Color, Color) {
        let pairs: [(Color, Color)] = [(clayOrange, clayBlue), (clayBlue, clayButter), (clayTeal, clayOrange),
                                       (clayPink, clayLavender), (clayButter, clayTeal), (clayLavender, clayPink)]
        return pairs[symbol.unicodeScalars.reduce(0) { $0 + Int($1.value) } % pairs.count]
    }

    private static func dynamic(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark
            ? UIColor(red: dark.0, green: dark.1, blue: dark.2, alpha: 1)
            : UIColor(red: light.0, green: light.1, blue: light.2, alpha: 1) })
    }
}
