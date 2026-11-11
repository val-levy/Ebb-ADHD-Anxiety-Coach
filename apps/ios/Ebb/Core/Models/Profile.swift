import Foundation

/// A row in `profiles`. Having one is what "signed in" means.
struct Profile: Codable, Equatable {
    let id: UUID
    var username: String
    var displayName: String
    var bio: String?
    var animal: AvatarAnimal

    enum CodingKeys: String, CodingKey {
        case id, username, bio, animal
        case displayName = "display_name"
    }
}
