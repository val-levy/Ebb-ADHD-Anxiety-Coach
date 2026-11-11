import Foundation

/// App state for resets: this week's history, which reset is playing, and whether a nudge is showing.
@MainActor
final class ResetStore: ObservableObject {
    @Published private(set) var week: [ResetEntry] = []
    @Published private(set) var weeklyInsights: [WeeklyInsight] = []
    @Published var activeReset: Reset?
    @Published var isNudgeShowing = false   // Demo: a real stress detector would set this

    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func load() async {
        try? await service.ensureSignedIn()
        let since = Date.now.addingTimeInterval(-7 * 86_400)
        week = (try? await service.resets(since: since)) ?? week
        let nudges = (try? await service.nudgeEvents(since: since)) ?? []
        weeklyInsights = WeeklyInsightBuilder.make(resets: week, nudges: nudges)
    }

    func record(_ reset: Reset, helped: Bool?) async {
        week.append(ResetEntry(kind: reset, helped: helped, created_at: .now)) // show instantly; server confirms on reload
        // ponytail: no offline queue; a failed insert is dropped. Add one if users rate resets offline.
        try? await service.insert(ResetEntry(kind: reset, helped: helped))
        await load()
    }

    var helpedCount: Int { week.filter { $0.helped == true }.count }

    func ratings(for reset: Reset) -> (helped: Int, rated: Int) {
        let rated = week.filter { $0.kind == reset && $0.helped != nil }
        return (rated.filter { $0.helped == true }.count, rated.count)
    }

    /// The reset that has helped most this week; paced breathing until there's data.
    var bestReset: Reset {
        let top = Reset.allCases.max { ratings(for: $0).helped < ratings(for: $1).helped }!
        return ratings(for: top).helped > 0 ? top : .breathe
    }
}
