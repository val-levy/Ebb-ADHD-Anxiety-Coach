import SwiftUI

/// One calm "this week" card on Reflect that opens the full insights screen.
struct WeekSummaryCard: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        NavigationLink { InsightsScreen() } label: {
            HStack(spacing: 12) {
                ClayIconTile(symbol: "leaf.fill", size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("This week").font(ClayFont.headline)
                    Text(store.helpedCount == 0 ? "See what's been helping you."
                                                : "\(store.helpedCount) resets helped 🌱")
                        .font(ClayFont.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(14)
            .clay()
        }
    }
}
