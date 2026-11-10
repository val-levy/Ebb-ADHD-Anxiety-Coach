import SwiftUI

/// The pacing circle. Holds still when Reduce Motion is on; prompts and haptics still guide.
struct BreathingCircle: View {
    let expanded: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.clear
            .frame(width: 240, height: 240)
            .clay(.white.opacity(0.4), radius: 120)   // soft clay ball
            .scaleEffect(reduceMotion ? 0.8 : (expanded ? 1 : 0.5))
            .accessibilityHidden(true)
    }
}
