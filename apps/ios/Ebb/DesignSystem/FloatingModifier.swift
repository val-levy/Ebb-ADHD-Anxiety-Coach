import SwiftUI

/// A gentle, endless bob up and down, like something resting on water. Off under Reduce Motion.
struct FloatingModifier: ViewModifier {
    var distance: CGFloat = 5
    @State private var up = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .compositingGroup()   // move as one flattened layer instead of re-rendering shadows/grain
            .offset(y: up ? -distance : distance)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { up = true }
            }
    }
}

extension View {
    func floating(_ distance: CGFloat = 5) -> some View { modifier(FloatingModifier(distance: distance)) }
}
