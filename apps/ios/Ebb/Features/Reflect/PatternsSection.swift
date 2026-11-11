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
            ForEach(Array(store.weeklyInsights.enumerated()), id: \.element.id) { index, insight in
                PatternRow(symbol: insight.symbol, text: insight.text).popIn(index)
            }
        }
    }
}
