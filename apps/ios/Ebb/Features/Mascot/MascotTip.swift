import SwiftUI

/// Marks a view as the spot for `tip`. When it's the screen's current tip, SceneScreen dims everything else,
/// spotlights this view, and the mascot explains it (see `TipCoach`).
struct MascotTip: ViewModifier {
    let tip: Tip
    @AppStorage("seenTips") private var seen: [String] = []

    func body(content: Content) -> some View {
        content.anchorPreference(key: TipSpotKey.self, value: .bounds) {
            Tip.current(on: tip.screen, seen: seen) == tip ? TipSpot(tip: tip, bounds: $0) : nil
        }
    }
}

struct TipSpot { let tip: Tip; let bounds: Anchor<CGRect> }

struct TipSpotKey: PreferenceKey {
    static var defaultValue: TipSpot?
    static func reduce(value: inout TipSpot?, nextValue: () -> TipSpot?) { value = value ?? nextValue() }
}

extension View {
    func mascotTip(_ tip: Tip) -> some View { modifier(MascotTip(tip: tip)) }
}
