import CoreGraphics

/// Every swipe stop in the app, left to right: Calm (Quick, then Guided), Reflect, Profile.
/// One sideways swipe moves one stop, so the Calm mode toggle and tab switching form a single chain.
enum AppPage: Int, CaseIterable {
    case calmQuick, calmGuided, reflect, profile

    enum Tab: Hashable { case calm, reflect, profile }

    var tab: Tab {
        switch self {
        case .calmQuick, .calmGuided: .calm
        case .reflect: .reflect
        case .profile: .profile
        }
    }

    init(tab: Tab, calmMode: CalmMode) {
        switch tab {
        case .calm: self = calmMode == .quick ? .calmQuick : .calmGuided
        case .reflect: self = .reflect
        case .profile: self = .profile
        }
    }

    /// Swipe left (dx < 0) goes to the next stop; swipe right goes back. Stays put at either end.
    func swiped(dx: CGFloat) -> AppPage {
        AppPage(rawValue: rawValue + (dx < 0 ? 1 : -1)) ?? self
    }
}
