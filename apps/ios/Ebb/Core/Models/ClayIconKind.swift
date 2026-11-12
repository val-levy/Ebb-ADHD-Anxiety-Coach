import Foundation

/// The hand-drawn clay icons used for buttons and controls (content tiles wear a `ClayFace` instead).
enum ClayIconKind {
    case chevronRight, chevronLeft, close, plus, check, play, next, speakerOn, speakerOff
    case trash, gear, pencil, arrowUp, grip, heart, star, sparkle, pill, chat, swap, clock, wind

    /// Solid shapes are filled; the rest are drawn as thick round-ended noodles.
    var filled: Bool {
        switch self {
        case .play, .next, .heart, .star, .sparkle, .speakerOn, .speakerOff, .pill, .chat, .wind: true
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
}
