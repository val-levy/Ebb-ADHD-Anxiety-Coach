/// The clay animal you pick as your profile picture (no photo uploads).
enum AvatarAnimal: String, CaseIterable, Identifiable, Codable {
    case panda, penguin, lion, elephant, giraffe, flamingo
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
}
