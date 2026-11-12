import Foundation

/// A guided session: an ordered set of techniques, like a class in a workout app.
enum CalmProgram: String, CaseIterable, Codable, Identifiable {
    case panic, breathe, ground, distract, cold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .panic: "I'm panicking right now"
        case .breathe: "Breathe it down"
        case .ground: "Ground me"
        case .distract: "Get out of my head"
        case .cold: "Cold reset"
        }
    }

    var mood: FaceMood {
        switch self {
        case .panic: .calm
        case .breathe: .calm
        case .ground: .steady
        case .distract: .wink
        case .cold: .brr
        }
    }

    var subtitle: String {
        switch self {
        case .panic: "The full walk-through: body, senses, mind"
        case .breathe: "Two ways to slow your heart"
        case .ground: "Settle your body and the room"
        case .distract: "Give your mind something else"
        case .cold: "A chilly trick to hit the brakes"
        }
    }

    /// Techniques in order. For `.panic`, the user's most helpful technique moves up to right after breathing.
    func techniques(favorite: CalmTechnique?) -> [CalmTechnique] {
        switch self {
        case .panic:
            var core: [CalmTechnique] = [.grounding, .muscleRelease, .mentalTask]
            if let favorite, ![.acknowledge, .cyclicSigh, .longExhale].contains(favorite) {
                core.removeAll { $0 == favorite }
                core.insert(favorite, at: 0)
            }
            return [.acknowledge, .cyclicSigh] + core + [.longExhale]
        case .breathe: return [.cyclicSigh, .longExhale]
        case .ground: return [.environment, .grounding]
        case .distract: return [.mentalTask, .grounding]
        case .cold: return [.coldReset, .longExhale]
        }
    }

    var minutes: Int { max(1, Int((techniques(favorite: nil).reduce(0) { $0 + $1.seconds } / 60).rounded())) }
}
