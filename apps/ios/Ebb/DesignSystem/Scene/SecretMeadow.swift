import SwiftUI

/// Hidden hills under the scene, uncovered as the content panel is pulled down (like Snapchat's pull-down).
/// The scene stays put; the panel slides away from the top, so the meadow reveals top-down.
/// Each guest pops up once the panel uncovers its spot, with a soft haptic tick. The deepest pull finds a balloon.
struct SecretMeadow: View {
    /// How far the page is pulled past the top, in points.
    let pull: CGFloat

    static let height: CGFloat = 440

    /// Guests: x as a fraction of width, y in points from the meadow's top.
    private let guests: [(x: Double, y: CGFloat, kind: Int)] =
        [(0.22, 90, 0), (0.75, 100, 1), (0.5, 170, 2), (0.16, 250, 3), (0.84, 260, 4), (0.6, 330, 5)]

    private var revealed: Int { guests.filter { isVisible(y: $0.y) }.count + (isVisible(y: 400) ? 1 : 0) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .topLeading) {
                Theme.hillNear
                HillShape(base: 0.28, crest: 0.16, peakAt: 0.3).fill(Theme.hillMeadow)
                HillShape(base: 0.55, crest: 0.42, peakAt: 0.7).fill(Theme.hillNear)
                HillShape(base: 0.82, crest: 0.68, peakAt: 0.35).fill(Theme.hillMeadow)
                ForEach(guests.indices, id: \.self) { i in
                    let g = guests[i]
                    guest(g.kind)
                        .scaleEffect(isVisible(y: g.y) ? 1 : 0.2, anchor: .bottom)
                        .opacity(isVisible(y: g.y) ? 1 : 0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isVisible(y: g.y))
                        .position(x: g.x * w, y: g.y - 20)
                }
                VStack(spacing: 6) {
                    HotAirBalloon()
                    Text("You found the secret meadow 🌼").font(ClayFont.footnote.bold()).foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 2)
                }
                .opacity(isVisible(y: 400) ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: isVisible(y: 400))
                .position(x: w * 0.5, y: 370)
                GrainOverlay(opacity: 0.18)
            }
        }
        .frame(height: Self.height)
        .sensoryFeedback(.impact(weight: .light), trigger: revealed) { old, new in new > old }
        .accessibilityHidden(true)
    }

    /// A spot is in view once the sliding panel has uncovered it (top-down; 40pt sits under the panel's lip).
    private func isVisible(y: CGFloat) -> Bool { pull > y + 50 }

    @ViewBuilder private func guest(_ kind: Int) -> some View {
        switch kind {
        case 0: Panda()
        case 1: Penguin()
        case 2: Flamingo()
        case 3: Giraffe().scaleEffect(0.8)
        case 4: Elephant()
        default: Lion()
        }
    }
}
