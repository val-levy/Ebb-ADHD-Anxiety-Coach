import SwiftUI

/// The deepest secret: a striped clay hot-air balloon that bobs gently.
struct HotAirBalloon: View {
    @State private var bob = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach([Theme.clayOrange, Theme.clayButter, Theme.clayPink, Theme.clayButter, Theme.clayOrange].indices, id: \.self) { i in
                    [Theme.clayOrange, Theme.clayButter, Theme.clayPink, Theme.clayButter, Theme.clayOrange][i]
                }
            }
            .frame(width: 60, height: 66)
            .clipShape(Ellipse())
            Path { p in
                p.move(to: CGPoint(x: 18, y: 58)); p.addLine(to: CGPoint(x: 25, y: 80))
                p.move(to: CGPoint(x: 42, y: 58)); p.addLine(to: CGPoint(x: 35, y: 80))
            }
            .stroke(.black.opacity(0.4), lineWidth: 1.2)
            .frame(width: 60, height: 90)
            RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.62, green: 0.42, blue: 0.28))
                .frame(width: 14, height: 10).offset(y: 42)
        }
        .frame(width: 60, height: 100)
        .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
        .drawingGroup()
        .offset(y: bob ? -8 : 4)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { bob = true }
        }
    }
}
