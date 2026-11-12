import SwiftUI

/// Gentle patterns from this week, or an encouraging empty state.
struct PatternsSection: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        if store.weeklyInsights.isEmpty {
            Text("A few resets this week will give Ebb something gentle to reflect back.")
                .font(ClayFont.subheadline)
                .foregroundStyle(.secondary)
                .padding()
                .clay()
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(store.weeklyInsights) { PatternRow(symbol: $0.symbol, text: $0.text) }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .clay()
        }
    }
}
