import Foundation

/// One user-editable time slot: a guard window (start–end), a planned nudge, or a medication reminder (start only).
struct ScheduleItem: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var start: Date
    var end: Date?
    var on = true

    static func at(_ hour: Int, _ minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }

    static let defaultGuards = [
        ScheduleItem(name: "Commute", start: at(8), end: at(9)),
        ScheduleItem(name: "Work block", start: at(13), end: at(17), on: false),
        ScheduleItem(name: "Evening", start: at(19), end: at(22))]
    static let defaultNudges = [ScheduleItem(name: "Midday check-in", start: at(12))]
}
