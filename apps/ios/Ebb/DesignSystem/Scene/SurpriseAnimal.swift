import SwiftUI

/// Every so often a surprise guest strolls across the hills: a giraffe, a lion or an elephant.
/// Waits a random while, walks one across with a gentle waddle, then hides again. Nothing appears under Reduce Motion.
struct SurpriseAnimal: View {
    let sceneWidth: CGFloat

    @State private var guest = 0
    @State private var visible = false
    @State private var across = false
    @State private var step = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let walkSeconds = 16.0

    var body: some View {
        Group {
            switch guest {
            case 0: Giraffe()
            case 1: Lion()
            default: Elephant()
            }
        }
        .rotationEffect(.degrees(step ? 3 : -3), anchor: .bottom)     // waddle
        .offset(x: across ? sceneWidth + 40 : -100)
        .opacity(visible ? 1 : 0)
        .task {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) { step = true }
            var first = true
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(first ? 4 : .random(in: 18...35)))
                first = false
                guest = .random(in: 0...2)
                visible = true
                withAnimation(.linear(duration: walkSeconds)) { across = true }
                try? await Task.sleep(for: .seconds(walkSeconds))
                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { visible = false; across = false }
            }
        }
    }
}
