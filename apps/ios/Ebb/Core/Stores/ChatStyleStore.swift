import Foundation

/// The user's optional extra instructions for the chat's tone. The chat function treats them as lowest priority.
@MainActor
final class ChatStyleStore: ObservableObject {
    static let limit = 500   // matches the table check
    @Published var text = ""
    @Published private(set) var saved = ""
    private let service: SupabaseService
    private var owner: UUID?

    init(service: SupabaseService) { self.service = service }

    var hasChanges: Bool { text != saved }

    /// Mirrors the chat function's filter: notes that touch scope, rules or the prompt are ignored there, so say so here.
    var willBeIgnored: Bool {
        text.contains(/\b(ignore|disregard|forget|override|bypass|jailbreak|pretend|role-?play|instructions?|rules?|prompt|system|refus\w*|medic\w*|dose|diagnos\w*|crisis|988|tools?|reveal|developer)\b/.ignoresCase())
    }

    func load() async {
        try? await service.ensureSignedIn()
        if owner != service.currentUserId { saved = ""; text = ""; owner = service.currentUserId }  // account swapped: never show the old one's note
        saved = (try? await service.chatStyle()) ?? saved
        text = saved
    }

    func save() async {
        let body = String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(Self.limit))
        guard body != saved else { return }
        if body.isEmpty { await clear(); return }
        try? await service.saveChatStyle(body)
        await load()
    }

    func clear() async {
        try? await service.clearChatStyle()
        await load()
    }
}
