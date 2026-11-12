import Foundation

/// The mascot's first-time tips. Each screen shows its own tips one at a time, in declaration order.
enum Tip: String, CaseIterable {
    case panic, modePicker, swipe, brainDump, pastDumps, chat, helped, avatar, friends, achievements

    enum Screen { case calm, reflect, profile }

    var screen: Screen {
        switch self {
        case .panic, .modePicker, .swipe: .calm
        case .brainDump, .pastDumps, .chat, .helped: .reflect
        case .avatar, .friends, .achievements: .profile
        }
    }

    var text: String {
        switch self {
        case .panic: "Panicking? Tap here anytime and I'll walk you through it."
        case .modePicker: "Quick resets take 90 seconds. Guided sessions go deeper."
        case .swipe: "Psst: swipe sideways anywhere to hop between screens."
        case .brainDump: "Head too full? Dump it all here and get one small next step."
        case .pastDumps: "Brain dumps you save wait here. Tap one to read it again."
        case .chat: "Chat with me and I'll log doses, stressors and brain dumps for you."
        case .helped: "Tap here to see what has been helping you."
        case .avatar: "Tap me to pick a different animal. I'll change too!"
        case .friends: "Invite friends so you can breathe together."
        case .achievements: "Little wins show up here as you go."
        }
    }

    /// The one tip to show on `screen` right now: its first unseen tip, or none.
    static func current(on screen: Screen, seen: [String]) -> Tip? {
        allCases.first { $0.screen == screen && !seen.contains($0.rawValue) }
    }

    static func selfCheck() {
        assert(current(on: .calm, seen: []) == .panic)
        assert(current(on: .calm, seen: ["panic"]) == .modePicker)
        assert(current(on: .reflect, seen: ["panic"]) == .brainDump)
        assert(current(on: .calm, seen: ["panic", "modePicker", "swipe"]) == nil)
    }
}
