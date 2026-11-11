import Foundation

/// A check-in shown to a person and the response they gave it. Mirrors a row in `nudge_events`.
struct NudgeEvent: Codable, Identifiable {
    var id: UUID?
    var origin: NudgeOrigin
    var outcome: NudgeOutcome
    var created_at: Date?

    init(origin: NudgeOrigin, outcome: NudgeOutcome = .shown, created_at: Date? = nil) {
        self.id = nil
        self.origin = origin
        self.outcome = outcome
        self.created_at = created_at
    }
}
