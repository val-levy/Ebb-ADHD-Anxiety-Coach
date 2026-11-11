import SwiftUI
import Charts

/// Each recent calm session as a line from how it felt before (butter) to after (teal). No axis numbers, just the shape of it.
struct CalmDropChart: View {
    @EnvironmentObject private var calm: CalmStore

    var body: some View {
        let points = CalmDropPoint.make(from: calm.history)
        let lighter = points.filter(\.feltLighter).count
        InsightCard(symbol: "wind", title: "After a calm session",
                    headline: points.isEmpty ? "Finish a guided session to see how it goes."
                                             : "\(lighter) of \(points.count) felt lighter afterwards") {
            if !points.isEmpty {
                Chart(points) { p in
                    RuleMark(x: .value("Session", p.date), yStart: .value("Before", p.before), yEnd: .value("After", p.after))
                        .foregroundStyle(Theme.tile).lineStyle(StrokeStyle(lineWidth: 5, lineCap: .round))
                    PointMark(x: .value("Session", p.date), y: .value("Before", p.before))
                        .foregroundStyle(Theme.clayButter).symbolSize(90)
                    PointMark(x: .value("Session", p.date), y: .value("After", p.after))
                        .foregroundStyle(Theme.clayTeal).symbolSize(90)
                }
                .chartYScale(domain: 0...10)
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(height: 120)
                .accessibilityLabel("\(lighter) of \(points.count) recent sessions felt lighter afterwards")
            }
        }
    }
}
