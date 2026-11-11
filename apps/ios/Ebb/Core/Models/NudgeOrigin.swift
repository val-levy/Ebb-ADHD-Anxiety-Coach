import Foundation

/// Why Ebb offered a check-in. `signal` is reserved for the future detector.
enum NudgeOrigin: String, Codable {
    case planned
    case preview
    case signal
}
