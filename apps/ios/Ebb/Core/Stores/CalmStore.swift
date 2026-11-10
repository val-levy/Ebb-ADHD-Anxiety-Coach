import Foundation

/// Calm sessions: history, personalization, and the session currently being run.
@MainActor
final class CalmStore: ObservableObject {
    @Published private(set) var history: [CalmSession] = []
    @Published var activeProgram: CalmProgram?

    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
    }

    func load() async {
        try? await service.ensureSignedIn()
        history = (try? await service.recentCalmSessions()) ?? history
    }

    func record(_ session: CalmSession) async {
        history.insert(session, at: 0)
        // ponytail: no offline queue (same as ResetStore); panic often happens offline, so add one before launch.
        try? await service.insert(session)
    }

    /// The technique the user picks most often as "what helped". Personalizes the panic program.
    var favoriteTechnique: CalmTechnique? {
        let picks = history.compactMap(\.helped_technique)
        return Dictionary(grouping: picks, by: { $0 }).max { $0.value.count < $1.value.count }?.key
    }

    /// Average before → after intensity over sessions that were rated at the end.
    var averageDrop: (before: Double, after: Double)? {
        let rated = history.filter { $0.intensity_after != nil }
        guard !rated.isEmpty else { return nil }
        let n = Double(rated.count)
        return (rated.reduce(0) { $0 + Double($1.intensity_before) } / n,
                rated.reduce(0) { $0 + Double($1.intensity_after!) } / n)
    }
}
