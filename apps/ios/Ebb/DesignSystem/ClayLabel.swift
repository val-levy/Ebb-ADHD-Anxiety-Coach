import SwiftUI

/// Title with a hand-drawn clay icon beside it (use where `Label(_, systemImage:)` would go).
struct ClayLabel: View {
    let title: String
    let icon: ClayIconKind
    var size: CGFloat = 20
    var tint: Color?

    init(_ title: String, _ icon: ClayIconKind, size: CGFloat = 20, tint: Color? = nil) { self.title = title; self.icon = icon; self.size = size; self.tint = tint }

    var body: some View {
        HStack(spacing: 6) { ClayIcon(kind: icon, size: size).foregroundStyle(tint.map(AnyShapeStyle.init) ?? AnyShapeStyle(.foreground)); Text(title) }
    }
}
