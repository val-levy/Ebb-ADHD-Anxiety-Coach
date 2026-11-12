import Foundation

/// The hand-drawn clay icons used for buttons and controls (content tiles wear a `ClayFace` instead).
enum ClayIconKind {
    case chevronRight, chevronLeft, close, plus, check, play, next, speakerOn, speakerOff
    case trash, gear, pencil, arrowUp, grip, heart, star, sparkle, pill, chat, swap, clock
    case wind, sun, moon, mountain, leaf, flame, cloud, rain, chart, calendar, phone, lock, briefcase, bolt, dots, people, walker, calmPerson, hand

    /// Solid shapes are filled; the rest are drawn as thick round-ended noodles.
    var filled: Bool {
        switch self {
        case .play, .next, .heart, .star, .sparkle, .speakerOn, .speakerOff, .pill, .chat, .moon, .leaf, .flame, .cloud, .rain, .bolt: true
        default: false
        }
    }

    /// Words VoiceOver can use when the icon stands alone.
    var label: String {
        switch self {
        case .chevronRight: "Next"
        case .chevronLeft: "Back"
        case .close: "Close"
        case .trash: "Delete"
        case .gear: "Settings"
        case .speakerOn: "Voice on"
        case .speakerOff: "Voice off"
        default: ""
        }
    }

    /// The informational icon that fits a content symbol (resets, techniques, stressors, insights, achievements).
    static func forSymbol(_ symbol: String) -> ClayIconKind {
        switch symbol {
        case "wind": .wind
        case "sun.max.fill": .sun
        case "moon.zzz.fill": .moon
        case "mountain.2.fill": .mountain
        case "leaf.fill": .leaf
        case "flame.fill": .flame
        case "cloud.fill": .cloud
        case "cloud.rain.fill": .rain
        case "chart.bar.xaxis": .chart
        case "calendar": .calendar
        case "phone.fill": .phone
        case "lock.fill": .lock
        case "briefcase.fill": .briefcase
        case "bolt.heart.fill": .bolt
        case "ellipsis.circle.fill": .dots
        case "person.2.fill": .people
        case "figure.walk": .walker
        case "figure.mind.and.body": .calmPerson
        case "hand.raised": .hand
        case "hand.thumbsup": .check
        case "heart.fill", "heart.text.square": .heart
        case "star.fill": .star
        case "pills.fill": .pill
        case "square.and.pencil": .pencil
        case "bubble.left.and.bubble.right.fill", "message.fill": .chat
        default: .sparkle
        }
    }
}
