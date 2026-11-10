import Foundation

/// The two kinds of help on the Calm tab: quick resets (≤90s) and longer guided sessions.
enum CalmMode: String, CaseIterable, Identifiable {
    case quick, guided
    var id: Self { self }

    var title: String { self == .quick ? "Quick reset" : "Guided" }
    var symbol: String { self == .quick ? "bolt.heart.fill" : "figure.mind.and.body" }
    var caption: String { self == .quick ? "90 seconds or less" : "A few minutes, step by step" }
}

