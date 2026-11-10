import Foundation

/// An evidence-based technique for bringing the body out of fight-or-flight.
/// Each one targets a different part of the panic loop (body, senses, thoughts, surroundings).
/// Wording stays in wellness language: no diagnosis or treatment claims.
enum CalmTechnique: String, CaseIterable, Codable, Identifiable {
    case acknowledge, cyclicSigh, longExhale, coldReset, grounding, muscleRelease, mentalTask, environment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .acknowledge: "Name it"
        case .cyclicSigh: "Cyclic sighing"
        case .longExhale: "Long exhale"
        case .coldReset: "Cold reset"
        case .grounding: "5-4-3-2-1 grounding"
        case .muscleRelease: "Tense and release"
        case .mentalTask: "Busy your mind"
        case .environment: "Change your space"
        }
    }

    /// One line on why it works, shown under the title during a session.
    var why: String {
        switch self {
        case .acknowledge: "Knowing it's a harmless alarm that passes breaks the fear-of-fear loop."
        case .cyclicSigh: "Double inhale, long exhale: shown to lower stress fast in a 2023 Stanford study."
        case .longExhale: "Exhaling longer than you inhale slows your heart through the vagus nerve."
        case .coldReset: "Cold on your face triggers the dive reflex, which slows your heart rate."
        case .grounding: "Focusing on your senses pulls attention out of the spiral and into now."
        case .muscleRelease: "Tensing then releasing muscles burns off adrenaline and shows your body it's safe."
        case .mentalTask: "A demanding task fills working memory, leaving less room for scary thoughts."
        case .environment: "Steady ground and less noise lower the input your alarm is reacting to."
        }
    }

    var source: String {
        switch self {
        case .acknowledge: "CBT for panic (Clark, 1986)"
        case .cyclicSigh: "Balban et al., Cell Reports Medicine, 2023"
        case .longExhale: "Slow-breathing & heart rate variability research"
        case .coldReset: "DBT TIPP skills (Linehan)"
        case .grounding: "Grounding / mindfulness-based approaches"
        case .muscleRelease: "Progressive muscle relaxation (Jacobson)"
        case .mentalTask: "Working-memory load & distraction research"
        case .environment: "Sensory regulation"
        }
    }

    var symbol: String {
        switch self {
        case .acknowledge: "heart.text.square"
        case .cyclicSigh: "lungs"
        case .longExhale: "wind"
        case .coldReset: "snowflake"
        case .grounding: "eye"
        case .muscleRelease: "hand.raised"
        case .mentalTask: "brain"
        case .environment: "house"
        }
    }

    var steps: [ResetStep] {
        switch self {
        case .acknowledge: [
            .init("This is your body's alarm going off.", 6, .still),
            .init("It feels awful, but it is not dangerous.", 6, .still),
            .init("It peaks, then fades. Usually within minutes.", 6, .still),
            .init("You don't have to fight it. Let's ride it out together.", 6, .still)]
        case .cyclicSigh:
            Array(repeating: [.init("Breathe in through your nose", 2, .expand), .init("Sip in a little more", 1, .expand, addsOn: true),
                              .init("Slowly let it all out through your mouth", 6, .contract)], count: 5).flatMap { $0 }
        case .longExhale:
            Array(repeating: [.init("In for 4", 4, .expand), .init("Out for 8", 8, .contract)], count: 5).flatMap { $0 }
        case .coldReset: [
            .init("If you can, splash cold water on your face, or hold something cold.", 10, .still),
            .init("Press it to your cheeks and forehead.", 15, .still),
            .init("Notice your heart starting to slow.", 10, .still)]
        case .grounding: [
            .init("Name 5 things you can see", 15, .still),
            .init("4 things you can touch", 12, .still),
            .init("3 things you can hear", 12, .still),
            .init("2 things you can smell", 10, .still),
            .init("1 thing you can taste", 8, .still)]
        case .muscleRelease: [
            .init("Squeeze your fists tight", 5, .expand), .init("Let go. Feel the difference.", 8, .contract),
            .init("Shrug your shoulders to your ears", 5, .expand), .init("Drop them.", 8, .contract),
            .init("Press your feet into the floor", 5, .expand), .init("Release.", 8, .contract)]
        case .mentalTask: [
            .init("Count backward from 100 by 7s", 25, .still),
            .init("Name an animal for each letter: A, B, C…", 25, .still)]
        case .environment: [
            .init("Plant both feet flat on the ground", 8, .still),
            .init("If you can, move somewhere quieter or dim the lights", 12, .still),
            .init("Look around slowly. Name where you are.", 10, .still)]
        }
    }

    var seconds: Double { steps.reduce(0) { $0 + $1.seconds } }
}
