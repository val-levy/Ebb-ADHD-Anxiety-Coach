import Foundation

/// Builds warm, non-clinical weekly reflections from saved activity; no inference beyond recorded actions.
struct WeeklyInsightBuilder {
    static func make(resets: [ResetEntry], nudges: [NudgeEvent]) -> [WeeklyInsight] {
        var insights: [WeeklyInsight] = []

        if let helpful = Reset.allCases
            .map({ reset in (reset, ratings(for: reset, in: resets)) })
            .filter({ $0.1.helped > 0 })
            .max(by: { $0.1.helped < $1.1.helped }) {
            let reset = helpful.0
            let rating = helpful.1
            let result = rating.rated == 1
                ? "\(reset.title) helped once this week."
                : "\(reset.title) helped \(rating.helped) of \(rating.rated) rated resets this week."
            insights.append(WeeklyInsight(id: "helped-\(reset.rawValue)", symbol: reset.symbol, text: result))
        }

        if let busiestDay = busiestDay(in: resets) {
            insights.append(WeeklyInsight(id: "day-\(busiestDay.date.formatted(date: .numeric, time: .omitted))",
                                          symbol: "calendar",
                                          text: "You reached for \(busiestDay.count) resets on \(busiestDay.date.formatted(.dateTime.weekday(.wide)))."))
        }

        let falseAlarms = nudges.filter { $0.outcome == .falseAlarm }.count
        if falseAlarms > 0 {
            let count = falseAlarms == 1 ? "One check-in" : "\(falseAlarms) check-ins"
            insights.append(WeeklyInsight(id: "false-alarms", symbol: "hand.thumbsup",
                                          text: "\(count) didn’t feel useful. That feedback helps Ebb adjust."))
        }

        return Array(insights.prefix(2))
    }

    private static func ratings(for reset: Reset, in entries: [ResetEntry]) -> (helped: Int, rated: Int) {
        let rated = entries.filter { $0.kind == reset && $0.helped != nil }
        return (rated.filter { $0.helped == true }.count, rated.count)
    }

    private static func busiestDay(in entries: [ResetEntry]) -> (date: Date, count: Int)? {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries.compactMap(\.created_at), by: { calendar.startOfDay(for: $0) })
        guard let busiest = grouped.max(by: { $0.value.count < $1.value.count }), busiest.value.count >= 2 else { return nil }
        return (busiest.key, busiest.value.count)
    }
}
