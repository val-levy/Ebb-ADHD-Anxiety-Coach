import SwiftUI

/// The mascot (your avatar animal) hiding behind something and peeking up every so often. Tap it for a wiggle.
/// Place it so its bottom is covered (behind a panel or edge); it rises from below and sinks back.
struct MascotPeek: View {
    var size: CGFloat = 54
    @AppStorage("profileAnimal") private var animal = AvatarAnimal.panda
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false
    @State private var wiggle = false

    var body: some View {
        AnimalFigure(animal: animal, size: size)
            .rotationEffect(.degrees(wiggle ? 8 : 0), anchor: .bottom)
            .offset(y: up || reduceMotion ? size * 0.15 : size * 0.9)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.3)) { wiggle = true }
                withAnimation(.spring.delay(0.25)) { wiggle = false }
            }
            .accessibilityHidden(true)
            .task {
                guard !reduceMotion else { return }
                try? await Task.sleep(for: .seconds(Double.random(in: 1...3)))
                while !Task.isCancelled {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { up = true }
                    try? await Task.sleep(for: .seconds(Double.random(in: 4...7)))
                    withAnimation(.easeIn(duration: 0.5)) { up = false }
                    try? await Task.sleep(for: .seconds(Double.random(in: 5...10)))
                }
            }
    }
}
