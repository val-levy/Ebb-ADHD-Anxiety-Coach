import Foundation

/// What a log is about. Raw values match the `kind` check in `life_logs`.
enum LogKind: String, Codable { case dose, stressor }

/// The stressor tags offered as one-tap chips.
enum Stressor: String, CaseIterable, Identifiable {
    case work, sleep, social, health, other
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .work: "briefcase.fill"
        case .sleep: "moon.zzz.fill"
        case .social: "person.2.fill"
        case .health: "heart.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}

/// A row in `life_logs`: a dose the user logged, or a stressor they tagged.
struct LogEntry: Codable {
    var kind: LogKind
    var tag: String?
    var source = "manual"
    var created_at: Date?   // server-set; nil when inserting
}
