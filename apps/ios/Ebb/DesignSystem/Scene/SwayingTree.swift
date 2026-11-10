import SwiftUI

/// A little cone tree that sways from its base, like it's in a light breeze.
struct SwayingTree: View {
    let height: CGFloat
    let delay: Double

    @State private var swayed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Triangle().fill(Theme.tree).frame(width: height * 0.64, height: height)
            Rectangle().fill(Theme.tree.opacity(0.8)).frame(width: 3, height: height * 0.35)
        }
        .rotationEffect(.degrees(swayed ? 3 : -3), anchor: .bottom)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(delay)) { swayed = true }
        }
    }
}
