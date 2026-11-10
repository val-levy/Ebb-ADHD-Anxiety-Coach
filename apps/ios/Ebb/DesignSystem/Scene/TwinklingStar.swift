import SwiftUI

/// A tiny night-sky star that fades in and out on its own rhythm.
struct TwinklingStar: View {
    let size: CGFloat
    let delay: Double

    @State private var dim = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle().fill(Theme.moon).frame(width: size, height: size)
            .opacity(dim ? 0.25 : 0.95)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.6 + delay).repeatForever(autoreverses: true).delay(delay)) { dim = true }
            }
    }
}
