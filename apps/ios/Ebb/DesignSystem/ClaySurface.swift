import SwiftUI

/// The clay look: a solid fill with a soft highlight (top-left) and soft dent (bottom-right) pressed in,
/// plus a gentle drop shadow so it sits on the canvas like a lump of play-dough.
struct ClaySurface: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content.background {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(color
                    .shadow(.inner(color: .white.opacity(0.55), radius: 5, x: 3, y: 4))
                    .shadow(.inner(color: .black.opacity(0.14), radius: 7, x: -3, y: -5)))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
        }
    }
}

extension View {
    func clay(_ color: Color = Theme.surface, radius: CGFloat = Theme.cardRadius) -> some View {
        modifier(ClaySurface(color: color, radius: radius))
    }
}
