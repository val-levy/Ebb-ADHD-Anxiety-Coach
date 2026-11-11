import Foundation

/// The brain dump draft (local) and the saved past dumps (Supabase, owner-only via RLS).
@MainActor
final class BrainDumpStore: ObservableObject {
    @Published var draft: String {
        didSet { UserDefaults.standard.set(draft, forKey: "dump") }
    }
    @Published private(set) var dumps: [BrainDump] = []
    private let service: SupabaseService

    init(service: SupabaseService) {
        self.service = service
        draft = UserDefaults.standard.string(forKey: "dump") ?? ""
    }

    /// Local text belongs to whoever wrote it: if the signed-in user changed, drop the draft and list instead of showing them.
    func load() async {
        let me = service.currentUserId?.uuidString
        let owner = UserDefaults.standard.string(forKey: "dumpOwner")
        if let owner, owner != me { draft = ""; dumps = [] }
        if let me { UserDefaults.standard.set(me, forKey: "dumpOwner") }
        if let loaded = try? await service.brainDumps() { dumps = loaded }
    }

    /// Files the draft as a past dump and clears it. A failed save keeps the draft so nothing is lost.
    func saveDraft() async {
        let body = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        let dump = BrainDump(body: body)
        do {
            try await service.insert(dump)
            dumps.insert(dump, at: 0)
            draft = ""
        } catch {}  // ponytail: silent; the draft stays so the user can tap again
    }

    func delete(_ dump: BrainDump) async {
        let before = dumps
        dumps.removeAll { $0.id == dump.id }
        do { try await service.deleteBrainDump(id: dump.id) } catch { dumps = before }
    }
}
