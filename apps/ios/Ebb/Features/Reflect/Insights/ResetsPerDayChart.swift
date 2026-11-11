import SwiftUI
import Charts

/// Soft bars: how many resets you did each day this week. Empty days are just quiet, never a miss.
struct ResetsPerDayChart: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        let days = DailyCount.make(from: store.week)
        let total = days.reduce(0) { $0 + $1.count }
        InsightCard(symbol: "figure.mind.and.body", title: "Resets this week",
                    headline: total == 0 ? "Your first reset will show up here." : "\(total) \(total == 1 ? "reset" : "resets") this week") {
            Chart(days) { d in
                BarMark(x: .value("Day", d.day, unit: .day), y: .value("Resets", d.count))
                    .foregroundStyle(Theme.clayTeal.gradient)
                    .cornerRadius(6)
            }
            .chartYAxis(.hidden)
            .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) } }
            .frame(height: 120)
            .accessibilityLabel("Resets per day this week, \(total) in total")
        }
    }
}
