import SwiftUI

/// One weekly pattern, as an icon tile and text (PatternsSection puts them all in one card).
struct PatternRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ClayIconTile(symbol: symbol)
            Text(text).font(ClayFont.subheadline)
            Spacer(minLength: 0)
        }
    }
}
