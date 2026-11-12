import Foundation

/// The chat thread. The model and its logging tools live in the `chat` Edge Function; this just talks to it.
@MainActor
final class ChatStore: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isSending = false
    @Published private(set) var failed = false
    private let service: SupabaseService
    private let afterActions: () async -> Void   // refresh the stores the chat just wrote to
    private var owner: UUID?

    init(service: SupabaseService, afterActions: @escaping () async -> Void) {
        self.service = service
        self.afterActions = afterActions
    }

    func load() async {
        try? await service.ensureSignedIn()
        if owner != service.currentUserId { messages = []; owner = service.currentUserId }  // account swapped: never show the old chat
        messages = (try? await service.chatMessages()) ?? messages
    }

    func send(_ text: String) async {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }
        failed = false; isSending = true
        messages.append(ChatMessage(role: "user", body: text))
        defer { isSending = false }
        do {
            let r = try await service.chat(text)
            messages.append(ChatMessage(role: "assistant", body: r.reply))
            if !r.actions.isEmpty { await afterActions() }
        } catch { failed = true }
    }
}
