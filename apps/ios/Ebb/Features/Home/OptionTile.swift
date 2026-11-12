import SwiftUI

/// A playful square tile for one reset or guided session: big bouncy icon, title, length.
struct OptionTile: View {
    let symbol: String
    let title: String
    let detail: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ClayIconTile(symbol: symbol, size: 44)
                Spacer(minLength: 0)
                Text(title).font(ClayFont.headline).lineLimit(2).multilineTextAlignment(.leading)
                Text(detail).font(ClayFont.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .padding()
            .clay()
        }
        .foregroundStyle(.primary)
    }
}
