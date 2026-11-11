import Foundation

/// A `notes` row: the user's brain dump.
struct Note: Codable {
    var body: String
    var updatedAt = Date()

    enum CodingKeys: String, CodingKey {
        case body
        case updatedAt = "updated_at"
    }
}
