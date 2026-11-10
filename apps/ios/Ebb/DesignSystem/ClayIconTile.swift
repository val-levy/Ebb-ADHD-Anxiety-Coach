import SwiftUI

/// A colorful two-tone icon in a pale rounded tile, with a soft clay highlight.
struct ClayIconTile: View {
    let symbol: String
    var size: CGFloat = 48
    @State private var bounce = false

    var body: some View {
        let (primary, secondary) = Theme.iconColors(for: symbol)
        Image(systemName: symbol)
            .symbolRenderingMode(.palette)
            .foregroundStyle(primary, secondary)
            .font(ClayFont.system(size: size * 0.46, weight: .bold))
            .symbolEffect(.bounce, value: bounce)   // little hop on appear; system honors Reduce Motion
            .shadow(color: primary.opacity(0.35), radius: 2, x: 0, y: 2)
            .frame(width: size, height: size)
            .background(Theme.tile, in: .rect(cornerRadius: Theme.tileRadius, style: .continuous))
            .accessibilityHidden(true)
            .onAppear { bounce.toggle() }
    }
}
