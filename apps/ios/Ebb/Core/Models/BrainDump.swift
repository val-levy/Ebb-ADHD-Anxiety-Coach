import Foundation

/// A saved brain dump (`brain_dumps` row). `user_id` is filled in by the database.
struct BrainDump: Codable, Identifiable, Equatable {
    var id = UUID()
    var body: String
    var createdAt = Date()

    enum CodingKeys: String, CodingKey {
        case id, body
        case createdAt = "created_at"
    }
}
