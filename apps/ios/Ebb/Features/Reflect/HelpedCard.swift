import SwiftUI

/// "Resets that helped" this week: a friendly count, then each rated reset with a little clay bar. Never a streak.
struct HelpedCard: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(store.helpedCount == 0 ? "Try a reset and rate it to see what works for you."
                                        : "\(store.helpedCount) resets helped this week 🌱")
                .font(ClayFont.headline)
            ForEach(Reset.allCases) { reset in
                let r = store.ratings(for: reset)
                if r.rated > 0 {
                    HStack(spacing: 12) {
                        ClayIconTile(symbol: reset.symbol, size: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(reset.title).font(ClayFont.subheadline.bold())
                                Spacer()
                                Text("\(r.helped) of \(r.rated)").font(ClayFont.subheadline).foregroundStyle(.secondary)
                            }
                            ClayBar(fraction: Double(r.helped) / Double(r.rated), color: Theme.iconColors(for: reset.symbol).0)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .clay()
    }
}
