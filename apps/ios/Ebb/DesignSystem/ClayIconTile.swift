import SwiftUI

/// A solid clay lump wearing a little face (a stable mood per `symbol` name), same look as the Calm tiles.
struct ClayIconTile: View {
    let symbol: String
    var size: CGFloat = 48

    var body: some View {
        let (primary, _) = Theme.iconColors(for: symbol)
        ClayFace(mood: .forSymbol(symbol), ink: .white.opacity(0.9), size: size * 0.78)
            .frame(width: size, height: size)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.tileRadius, style: .continuous)) }
            .clay(primary, radius: Theme.tileRadius)
            .accessibilityHidden(true)
    }
}
