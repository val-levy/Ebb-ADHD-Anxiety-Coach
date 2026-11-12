import Foundation

/// The reset types. Raw values match the `reset_kind` enum in Postgres.
enum Reset: String, CaseIterable, Codable, Identifiable {
    case breathe, sigh, ground, body

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breathe: "Slow Tide"
        case .sigh: "Sigh Balloon"
        case .ground: "Pebble Hunt"
        case .body: "Noodle Break"
        }
    }

    var blurb: String {
        switch self {
        case .breathe: "Slow in, long out"
        case .sigh: "Two sips in, one big sigh out"
        case .ground: "Spot what's around you"
        case .body: "Stand up, sip water, look away"
        }
    }

    var length: String {
        switch self {
        case .breathe: "60 sec"
        case .sigh: "30 sec"
        case .ground: "45 sec"
        case .body: "90 sec"
        }
    }

    var mood: FaceMood {
        switch self {
        case .breathe: .puff
        case .sigh: .sigh
        case .ground: .alert
        case .body: .cheer
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
