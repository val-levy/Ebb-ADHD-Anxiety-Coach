import Foundation

/// This week's life logs (doses and stressors) and the one-tap ways to add more.
@MainActor
final class LogStore: ObservableObject {
    @Published private(set) var week: [LogEntry] = []
    private let service: SupabaseService

    init(service: SupabaseService) { self.service = service }

    func load() async {
        try? await service.ensureSignedIn()
        week = (try? await service.logs(since: .now.addingTimeInterval(-7 * 86_400))) ?? week
    }

    func logDose() async { await add(LogEntry(kind: .dose)) }
    func logStressor(_ s: Stressor) async { await add(LogEntry(kind: .stressor, tag: s.title)) }

    private func add(_ entry: LogEntry) async {
        var shown = entry; shown.created_at = .now
        week.append(shown)   // show instantly; server confirms on reload
        try? await service.insert(entry)
        await load()
    }

    /// Start-of-day for each day with a logged dose.
    var doseDays: Set<Date> {
        Set(week.filter { $0.kind == .dose }.compactMap { $0.created_at.map { Calendar.current.startOfDay(for: $0) } })
    }
}
