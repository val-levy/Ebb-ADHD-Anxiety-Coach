import Foundation

/// One rated calm session: how it felt going in and coming out (0–10, self-rated). Feeds the "after a session" chart.
struct CalmDropPoint: Identifiable {
    let date: Date
    let before: Int
    let after: Int
    var id: Date { date }
    var feltLighter: Bool { after < before }

    /// Newest `limit` sessions that were rated at the end, oldest first.
    static func make(from sessions: [CalmSession], limit: Int = 7) -> [CalmDropPoint] {
        let rated = sessions.compactMap { s -> CalmDropPoint? in
            guard let after = s.intensity_after, let date = s.created_at else { return nil }
            return CalmDropPoint(date: date, before: s.intensity_before, after: after)
        }
        return Array(rated.sorted { $0.date > $1.date }.prefix(limit).reversed())
    }
}
