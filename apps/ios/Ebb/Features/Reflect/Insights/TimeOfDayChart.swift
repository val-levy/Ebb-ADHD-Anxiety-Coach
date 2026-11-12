import SwiftUI
import Charts

/// When in the day you tend to reach for a reset.
struct TimeOfDayChart: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        let parts = LogInsights.timeOfDay(store.week)
        let top = parts.max { $0.count < $1.count }
        InsightCard(symbol: "sun.max.fill", title: "Time of day",
                    headline: (top?.count ?? 0) == 0 ? "Your resets will show when in the day." : "Mostly \(top!.name.lowercased())s") {
            Chart(parts) { p in
                BarMark(x: .value("Part", p.name), y: .value("Resets", p.count))
                    .foregroundStyle(Theme.clayTeal.gradient).cornerRadius(6)
            }
            .chartYAxis(.hidden)
            .frame(height: 110)
        }
    }
}
