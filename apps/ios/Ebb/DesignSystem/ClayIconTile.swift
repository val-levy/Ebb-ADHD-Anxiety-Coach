import SwiftUI

/// A solid clay lump holding a custom icon that fits the item (same look as the Calm tiles, which keep their faces).
struct ClayIconTile: View {
    let symbol: String
    var size: CGFloat = 48

    var body: some View {
        let (primary, _) = Theme.iconColors(for: symbol)
        ClayIcon(kind: .forSymbol(symbol), size: size * 0.55)
            .foregroundStyle(.white.opacity(0.95))
            .frame(width: size, height: size)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.tileRadius, style: .continuous)) }
            .clay(primary, radius: Theme.tileRadius)
            .accessibilityHidden(true)
    }
}
