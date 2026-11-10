import SwiftUI

/// Slides content left-to-right across `distance` forever (wrapping), starting partway through at `start` (0...1).
/// Pure transform animation: content renders once and the GPU moves it, so it's smooth at any frame rate.
struct DriftModifier: ViewModifier {
    let distance: CGFloat
    let duration: Double
    let start: Double

    @State private var moving = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(x: looped ? (moving ? distance : 0) : distance * (moving ? 1 : start))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: duration * (1 - start))) { moving = true } completion: { loop() }
            }
    }

    @State private var looped = false

    /// After the first partial pass, jump back to the start edge and repeat full passes.
    private func loop() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { moving = false; looped = true }
        DispatchQueue.main.async {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) { moving = true }
        }
    }
}

extension View {
    func drift(distance: CGFloat, duration: Double, start: Double = 0) -> some View {
        modifier(DriftModifier(distance: distance, duration: duration, start: start))
    }
}
