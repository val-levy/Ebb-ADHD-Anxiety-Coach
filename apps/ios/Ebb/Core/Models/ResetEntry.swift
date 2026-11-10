import Foundation

/// A completed reset and its optional rating. Mirrors a row in the `resets` table.
struct ResetEntry: Codable {
    var kind: Reset
    var helped: Bool?          // nil = user skipped the rating
    var created_at: Date?      // set by the server; nil when inserting
}
