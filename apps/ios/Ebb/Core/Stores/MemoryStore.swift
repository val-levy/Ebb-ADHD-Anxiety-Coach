import Foundation

/// What the chat remembers about you. Read it, fix it, or clear it.
@MainActor
final class MemoryStore: ObservableObject {
    static let limit = 900   // matches what the chat function writes
    @Published var text = ""
    @Published private(set) var saved = ""
    private let service: SupabaseService
    private var owner: UUID?

    init(service: SupabaseService) { self.service = service }

    var hasChanges: Bool { text != saved }

    func load() async {
        try? await service.ensureSignedIn()
        if owner != service.currentUserId { saved = ""; text = ""; owner = service.currentUserId }  // account swapped: never show the old one's memory
        saved = (try? await service.memory()) ?? saved
        text = saved
    }

    func save() async {
        let body = String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.limit))
        guard body != saved else { return }
        if body.isEmpty { await clear(); return }
        try? await service.saveMemory(body)
        await load()
    }

    func clear() async {
        try? await service.clearMemory()
        await load()
    }
}
