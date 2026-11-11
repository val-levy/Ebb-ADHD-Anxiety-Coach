import SwiftUI

/// The shared frame for every insight graph: a title, one big friendly line, then the chart. New graphs just fill `content`.
struct InsightCard<Content: View>: View {
    let symbol: String
    let title: String
    let headline: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ClayIconTile(symbol: symbol, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(ClayFont.footnote).foregroundStyle(.secondary)
                    Text(headline).font(ClayFont.headline)
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .clay()
    }
}
