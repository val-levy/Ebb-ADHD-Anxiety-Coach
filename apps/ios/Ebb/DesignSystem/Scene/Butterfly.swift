import SwiftUI

/// A clay butterfly: two-tone wings that flap while it bobs up and down on its way across.
struct Butterfly: View {
    let color: Color
    let delay: Double

    @State private var flap = false
    @State private var bob = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                wing.scaleEffect(x: flap ? 0.25 : 1, anchor: .trailing)
                wing.scaleEffect(x: flap ? -0.25 : -1, anchor: .leading)
            }
            Capsule().fill(.black.opacity(0.65)).frame(width: 2.5, height: 10)
        }
        .offset(y: bob ? -10 : 6)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true).delay(delay)) { flap = true }
            withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true).delay(delay)) { bob = true }
        }
    }

    private var wing: some View {
        VStack(spacing: 0) {
            Ellipse().fill(color).frame(width: 9, height: 8)
            Ellipse().fill(color.opacity(0.75)).frame(width: 6, height: 6)
        }
        .frame(width: 9)
        .drawingGroup()
    }
}
