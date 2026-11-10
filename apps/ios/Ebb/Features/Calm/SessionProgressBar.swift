import SwiftUI

/// Segmented bar, one segment per technique, like chapters in a class. The current segment fills smoothly as you go,
/// so you can always see how far you've come (less "stuck in it", more "almost there").
struct SessionProgressBar: View {
    let count: Int
    let current: Int
    /// How much of the current technique is done, 0...1. Animated by the player, drawn as a scale (transform-only).
    let fill: Double

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(.white.opacity(0.3))
                    .overlay(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.95))
                            .scaleEffect(x: i < current ? 1 : i == current ? fill : 0, anchor: .leading)
                    }
                    .clipShape(Capsule())
                    .frame(height: 8)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Step \(current + 1) of \(count)")
        .accessibilityValue("\(Int(fill * 100)) percent through this step")
    }
}
