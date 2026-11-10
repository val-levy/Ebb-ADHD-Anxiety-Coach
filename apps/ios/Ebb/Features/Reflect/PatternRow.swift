import SwiftUI

/// One weekly pattern, as a clay card with an icon tile.
struct PatternRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ClayIconTile(symbol: symbol)
            Text(text).font(ClayFont.subheadline)
            Spacer(minLength: 0)
        }
        .padding()
        .clay()
    }
}
