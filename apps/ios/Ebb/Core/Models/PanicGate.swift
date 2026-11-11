import Foundation

/// What happens when someone starts a panic session. Signed-in users are always `.free`;
/// anonymous users climb a ladder by how many panic sessions they've started before.
enum PanicGate: Equatable {
    case free, promptAfter, promptBeforeSkippable, blocked

    static func decide(usesSoFar: Int, signedIn: Bool) -> PanicGate {
        if signedIn { return .free }
        switch usesSoFar {
        case 0: return .promptAfter
        case 1: return .promptBeforeSkippable
        default: return .blocked
        }
    }

    static func selfCheck() {
        assert(decide(usesSoFar: 0, signedIn: false) == .promptAfter)
        assert(decide(usesSoFar: 1, signedIn: false) == .promptBeforeSkippable)
        assert(decide(usesSoFar: 2, signedIn: false) == .blocked)
        assert(decide(usesSoFar: 9, signedIn: false) == .blocked)
        assert(decide(usesSoFar: 5, signedIn: true) == .free)
        let c = KeychainCounter(key: "selfCheck"), n = c.value
        c.increment()
        assert(c.value == n + 1, "KeychainCounter didn't increment")
    }
}
