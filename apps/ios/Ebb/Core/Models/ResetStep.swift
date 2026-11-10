import Foundation

/// One phase of a guided reset or calm session: what to say, how long, and which way the breathing circle moves.
struct ResetStep {
    enum Motion { case expand, contract, still }

    let prompt: String
    let seconds: Double
    let motion: Motion
    /// Shown under the previous prompt instead of replacing it (e.g. "Sip in a little more").
    let addsOn: Bool

    init(_ prompt: String, _ seconds: Double, _ motion: Motion, addsOn: Bool = false) {
        self.prompt = prompt
        self.seconds = seconds
        self.motion = motion
        self.addsOn = addsOn
    }
}
