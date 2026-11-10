import SwiftUI

/// A little clay flower on a stem, swaying from the ground.
struct SwayingFlower: View {
    let petal: Color
    let height: CGFloat
    let delay: Double

    @State private var swayed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: -2) {
            ZStack {
                ForEach(0..<5, id: \.self) { i in
                    Circle().fill(petal)
                        .frame(width: height * 0.32)
                        .offset(y: -height * 0.16)
                        .rotationEffect(.degrees(Double(i) * 72))
                }
                Circle().fill(Theme.clayButter).frame(width: height * 0.22)
            }
            .frame(width: height * 0.64, height: height * 0.64)
            Capsule().fill(Theme.hillFar).frame(width: 2.5, height: height * 0.6)
        }
        .drawingGroup()
        .rotationEffect(.degrees(swayed ? 6 : -6), anchor: .bottom)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(delay)) { swayed = true }
        }
    }
}
