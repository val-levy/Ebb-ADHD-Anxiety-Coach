import Foundation

/// One chat bubble. `id` is local; rows from the server get a fresh one.
struct ChatMessage: Identifiable, Decodable {
    let id = UUID()
    let role: String   // "user" | "assistant"
    let body: String
    var isUser: Bool { role == "user" }

    private enum CodingKeys: String, CodingKey { case role, body }
    init(role: String, body: String) { self.role = role; self.body = body }
}

/// What the `chat` Edge Function returns.
struct ChatReply: Decodable {
    let reply: String
    let actions: [String]   // e.g. "Logged a dose", "Tagged Work"
}
