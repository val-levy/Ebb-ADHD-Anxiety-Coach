import SwiftUI

/// Makes an SF Symbol look pressed into clay: chunky weight, a soft highlight on top and a small shadow below.
struct ClayGlyph: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.heavy)
            .shadow(color: .white.opacity(0.45), radius: 0, x: -0.5, y: -0.5)
            .shadow(color: .black.opacity(0.22), radius: 1, x: 0, y: 1.5)
    }
}

extension View {
    func clayGlyph() -> some View { modifier(ClayGlyph()) }
}

/// App-wide label style: the icon gets the clay treatment, the title stays as is.
struct ClayLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label { configuration.title } icon: { configuration.icon.clayGlyph() }
            .labelStyle(.titleAndIcon)
    }
}
