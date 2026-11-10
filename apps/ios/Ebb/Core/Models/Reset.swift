import Foundation

/// The reset types. Raw values match the `reset_kind` enum in Postgres.
enum Reset: String, CaseIterable, Codable, Identifiable {
    case breathe, sigh, ground, body

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breathe: "Paced breathing"
        case .sigh: "Physiological sigh"
        case .ground: "Grounding"
        case .body: "Body break"
        }
    }

    var blurb: String {
        switch self {
        case .breathe: "60s · slow taps, long exhale"
        case .sigh: "30s · two inhales, one long exhale"
        case .ground: "45s · notice what's around you"
        case .body: "90s · stand, water, look away"
        }
    }

    var symbol: String {
        switch self {
        case .breathe: "wind"
        case .sigh: "lungs"
        case .ground: "eye"
        case .body: "figure.walk"
        }
    }

    /// The guided sequence. Long exhales are the point.
    var steps: [ResetStep] {
        switch self {
        case .breathe:
            repeated([.init("Breathe in", 4, .expand), .init("Breathe out slowly", 6, .contract)], times: 6)
        case .sigh:
            repeated([.init("Inhale", 2, .expand), .init("Inhale a little more", 1, .expand), .init("Long exhale", 6, .contract)], times: 3)
        case .ground:
            [.init("Name 3 things you can see", 15, .expand), .init("2 things you can hear", 15, .contract), .init("1 thing you can feel", 15, .expand)]
        case .body:
            [.init("Stand up", 20, .expand), .init("Drink some water", 40, .contract), .init("Look out a window", 30, .expand)]
        }
    }

    private func repeated(_ cycle: [ResetStep], times: Int) -> [ResetStep] {
        Array(repeating: cycle, count: times).flatMap { $0 }
    }
}
