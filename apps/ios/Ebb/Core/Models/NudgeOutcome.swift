import Foundation

/// The one-tap response to a check-in offer.
enum NudgeOutcome: String, Codable {
    case shown
    case accepted
    case dismissed
    case snoozed
    case falseAlarm = "false_alarm"
}
