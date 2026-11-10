import SwiftUI

/// Dark-mode moon: a soft crescent with a slowly breathing glow.
struct MoonView: View {
    let size: CGFloat

    @State private var glow = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().fill(Theme.moon.opacity(0.18)).frame(width: size * 1.7)
                .scaleEffect(glow ? 1.08 : 0.94)
            ZStack {
                Circle().fill(Theme.moon)
                Circle().offset(x: size * 0.32, y: -size * 0.12).blendMode(.destinationOut)   // bite out a crescent
            }
            .compositingGroup()
            .frame(width: size, height: size)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { glow = true }
        }
    }
}
