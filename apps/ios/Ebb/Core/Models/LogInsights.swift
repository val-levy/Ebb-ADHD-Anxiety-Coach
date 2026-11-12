import Foundation

/// Pure shapers that turn raw logs and resets into what the insight cards draw.
enum LogInsights {
    struct TagCount: Identifiable { let tag: String; let count: Int; var id: String { tag } }
    struct Part: Identifiable { let name: String; let count: Int; var id: String { name } }

    /// Stressor tags this week, most frequent first.
    static func stressorCounts(_ logs: [LogEntry]) -> [TagCount] {
        let tags = logs.filter { $0.kind == .stressor }.compactMap(\.tag)
        return Dictionary(grouping: tags, by: { $0 }).map { TagCount(tag: $0.key, count: $0.value.count) }
            .sorted { ($0.count, $1.tag) > ($1.count, $0.tag) }
    }

    /// Resets by part of the day.
    static func timeOfDay(_ resets: [ResetEntry], calendar: Calendar = .current) -> [Part] {
        let names = ["Night", "Morning", "Afternoon", "Evening"]
        var counts = [0, 0, 0, 0]
        for date in resets.compactMap(\.created_at) {
            let h = calendar.component(.hour, from: date)
            counts[h < 6 ? 0 : h < 12 ? 1 : h < 18 ? 2 : 3] += 1
        }
        return [1, 2, 3, 0].map { Part(name: names[$0], count: counts[$0]) }
    }

    /// Average stressors tagged per day, split by whether a dose was logged that day. Describes the user's own days, nothing more.
    static func stressorsByDose(_ logs: [LogEntry], calendar: Calendar = .current) -> (withDose: Double, without: Double)? {
        let days = Dictionary(grouping: logs.compactMap { l in l.created_at.map { (calendar.startOfDay(for: $0), l) } }, by: \.0)
        var yes = [Int](), no = [Int]()
        for day in days.values {
            let stress = day.filter { $0.1.kind == .stressor }.count
            if day.contains(where: { $0.1.kind == .dose }) { yes.append(stress) } else { no.append(stress) }
        }
        guard !yes.isEmpty, !no.isEmpty else { return nil }
        let avg = { (a: [Int]) in Double(a.reduce(0, +)) / Double(a.count) }
        return (avg(yes), avg(no))
    }

    static func selfCheck() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let logs = [LogEntry(kind: .dose, created_at: now), LogEntry(kind: .stressor, tag: "work", created_at: now),
                    LogEntry(kind: .stressor, tag: "work", created_at: now.addingTimeInterval(-86_400))]
        assert(stressorCounts(logs).first?.count == 2)
        let r = stressorsByDose(logs)
        assert(r?.withDose == 1 && r?.without == 1)
    }
}
