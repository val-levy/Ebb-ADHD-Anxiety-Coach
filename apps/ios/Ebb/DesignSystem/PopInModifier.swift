import SwiftUI

/// Springs content in on first appear (rise + grow + fade), staggered by `order`. Plain fade under Reduce Motion.
struct PopInModifier: ViewModifier {
    let order: Int
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown || reduceMotion ? 1 : 0.92)
            .offset(y: shown || reduceMotion ? 0 : 24)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(Double(order) * 0.07)) { shown = true }
            }
    }
}

extension View {
    func popIn(_ order: Int = 0) -> some View { modifier(PopInModifier(order: order)) }
}
