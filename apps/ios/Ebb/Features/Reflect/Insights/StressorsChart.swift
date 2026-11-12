import SwiftUI
import Charts

/// Which stressors you tagged this week.
struct StressorsChart: View {
    @EnvironmentObject private var logs: LogStore

    var body: some View {
        let counts = LogInsights.stressorCounts(logs.week)
        InsightCard(symbol: "cloud.rain.fill", title: "Stressors this week",
                    headline: counts.first.map { "\($0.tag) came up most" } ?? "Tags you add will show up here.") {
            if !counts.isEmpty {
                Chart(counts) { c in
                    BarMark(x: .value("Count", c.count), y: .value("Stressor", c.tag))
                        .foregroundStyle(Theme.clayTeal.gradient).cornerRadius(6)
                }
                .chartXAxis(.hidden)
                .frame(height: CGFloat(counts.count) * 34 + 10)
            }
        }
    }
}
