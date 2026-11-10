import SwiftUI

/// Night replacement for butterflies: a glowing dot that wanders in a small loop and pulses.
struct Firefly: View {
    let delay: Double

    @State private var wander = false
    @State private var lit = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle().fill(Theme.firefly).frame(width: 4, height: 4)
            .background(Circle().fill(Theme.firefly.opacity(0.35)).frame(width: 12, height: 12))
            .opacity(lit ? 1 : 0.2)
            .offset(x: wander ? 14 : -10, y: wander ? -12 : 8)
            .onAppear {
                guard !reduceMotion else { lit = true; return }
                withAnimation(.easeInOut(duration: 3.5 + delay).repeatForever(autoreverses: true).delay(delay)) { wander = true }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(delay)) { lit = true }
            }
    }
}
