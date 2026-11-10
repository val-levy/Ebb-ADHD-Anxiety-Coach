import SwiftUI

/// A small clay bunny that hops along the hill.
struct HoppingBunny: View {
    @State private var up = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let fur = Color(red: 0.96, green: 0.93, blue: 0.88)

    var body: some View {
        ZStack {
            Ellipse().fill(fur).frame(width: 22, height: 16).offset(x: -2, y: 4)               // body
            Circle().fill(.white).frame(width: 7).offset(x: -13, y: 3)                        // tail
            Circle().fill(fur).frame(width: 12).offset(x: 8, y: -3)                            // head
            Capsule().fill(fur).frame(width: 4, height: 12).rotationEffect(.degrees(12)).offset(x: 7, y: -13)
            Capsule().fill(fur).frame(width: 4, height: 12).rotationEffect(.degrees(28)).offset(x: 11, y: -12)
            Circle().fill(.black.opacity(0.7)).frame(width: 2).offset(x: 11, y: -4)            // eye
        }
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
        .offset(y: up ? -9 : 0)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.32).repeatForever(autoreverses: true)) { up = true }
        }
    }
}
