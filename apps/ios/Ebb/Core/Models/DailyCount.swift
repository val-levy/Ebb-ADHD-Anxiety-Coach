import Foundation

/// How many resets happened on one day. Feeds the "resets per day" chart.
struct DailyCount: Identifiable {
    let day: Date
    let count: Int
    var id: Date { day }

    /// The last `days` days ending today, oldest first, zero-filled so the chart always has every day.
    static func make(from entries: [ResetEntry], days: Int = 7, now: Date = .now, calendar: Calendar = .current) -> [DailyCount] {
        let today = calendar.startOfDay(for: now)
        return (0..<days).reversed().map { back in
            let day = calendar.date(byAdding: .day, value: -back, to: today)!
            let n = entries.filter { $0.created_at.map { calendar.isDate($0, inSameDayAs: day) } ?? false }.count
            return DailyCount(day: day, count: n)
        }
    }

    static func selfCheck() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let made = make(from: [ResetEntry(kind: .breathe, helped: nil, created_at: now)], now: now)
        assert(made.count == 7 && made.last?.count == 1 && made.first?.count == 0)
    }
}
