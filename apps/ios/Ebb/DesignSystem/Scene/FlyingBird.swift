import SwiftUI

/// A small bird: a "V" that flaps its wings while gliding across the sky.
struct FlyingBird: View {
    let size: CGFloat
    let flapDelay: Double

    @State private var flap = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: 0))
            p.addQuadCurve(to: CGPoint(x: size / 2, y: size * 0.3), control: CGPoint(x: size * 0.25, y: -size * 0.1))
            p.addQuadCurve(to: CGPoint(x: size, y: 0), control: CGPoint(x: size * 0.75, y: -size * 0.1))
        }
        .stroke(Color.black.opacity(0.55), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size * 0.4)
        .scaleEffect(y: flap ? -0.6 : 1, anchor: .center)   // wings up / down
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(flapDelay)) { flap = true }
        }
    }
}
