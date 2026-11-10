import SwiftUI

/// Light-mode sun: a warm clay disc with rays that turn very slowly.
struct SunView: View {
    let size: CGFloat

    @State private var turned = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                Capsule().fill(Theme.sun.opacity(0.7))
                    .frame(width: size * 0.09, height: size * 0.22)
                    .offset(y: -size * 0.72)
                    .rotationEffect(.degrees(Double(i) * 36))
            }
            .drawingGroup()
            .rotationEffect(.degrees(turned ? 360 : 0))
            Circle().fill(Theme.sun).frame(width: size, height: size)
                .shadow(color: Theme.sun.opacity(0.6), radius: size * 0.25)
        }
        .frame(width: size * 1.8, height: size * 1.8)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) { turned = true }
        }
    }
}
