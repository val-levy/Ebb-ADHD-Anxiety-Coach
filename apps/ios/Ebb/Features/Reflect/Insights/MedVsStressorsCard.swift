import SwiftUI
import Charts

/// Stressors tagged per day, on days you logged a dose next to days you didn't.
/// It shows your own days side by side and says nothing about why.
struct MedVsStressorsCard: View {
    @EnvironmentObject private var logs: LogStore

    var body: some View {
        let r = LogInsights.stressorsByDose(logs.week)
        InsightCard(symbol: "chart.bar.xaxis", title: "Doses and stressors",
                    headline: r == nil ? "Log a few days and this fills in." : "Your days, side by side") {
            if let r {
                let rows = [("Dose logged", r.withDose), ("No dose logged", r.without)]
                Chart(rows, id: \.0) { row in
                    BarMark(x: .value("Day type", row.0), y: .value("Stressors per day", row.1))
                        .foregroundStyle(Theme.clayTeal.gradient).cornerRadius(6)
                        .annotation(position: .top) {
                            Text(row.1.formatted(.number.precision(.fractionLength(0...1)))).font(ClayFont.footnote)
                        }
                }
                .chartYAxis(.hidden)
                .frame(height: 120)
                Text("Average stressors you tagged per day.").font(ClayFont.footnote).foregroundStyle(.secondary)
            }
        }
    }
}
