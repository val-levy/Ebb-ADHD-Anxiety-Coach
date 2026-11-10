import SwiftUI

/// The view behind `SquishyButtonStyle`. It holds the squish animation state.
struct SquishyButton: View {
    let configuration: PrimitiveButtonStyleConfiguration
    @State private var squished = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .contentShape(.rect)
            .scaleEffect(squished ? 0.94 : 1)
            .onTapGesture {
                guard !reduceMotion else { return configuration.trigger() }
                withAnimation(.spring(response: 0.18, dampingFraction: 0.6)) { squished = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) { squished = false }
                    configuration.trigger()
                }
            }
            .accessibilityAddTraits(.isButton)
    }
}
