import SwiftUI

/// A solid clay lump with a chunky white symbol pressed into it (same look as the Calm tiles).
struct ClayIconTile: View {
    let symbol: String
    var size: CGFloat = 48
    @State private var bounce = false

    var body: some View {
        let (primary, _) = Theme.iconColors(for: symbol)
        Image(systemName: symbol)
            .font(ClayFont.system(size: size * 0.46, weight: .heavy))
            .foregroundStyle(.white)
            .clayGlyph()
            .symbolEffect(.bounce, value: bounce)   // little hop on appear; system honors Reduce Motion
            .frame(width: size, height: size)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.tileRadius, style: .continuous)) }
            .clay(primary, radius: Theme.tileRadius)
            .accessibilityHidden(true)
            .onAppear { bounce.toggle() }
    }
}
