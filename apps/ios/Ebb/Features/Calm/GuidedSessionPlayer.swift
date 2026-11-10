import SwiftUI

/// The "class": plays each technique's steps in order with voice, haptics, a breathing circle and a progress bar.
struct GuidedSessionPlayer: View {
    let techniques: [CalmTechnique]
    let onFinish: () -> Void

    @AppStorage("guideVoiceOn") private var voiceOn = true
    @AppStorage("breathRate") private var rate = 8.0
    @State private var voice = GuideVoice()
    @State private var techniqueIndex = 0
    @State private var prompt = ""
    @State private var expanded = false
    @State private var skipRequested = false
    @State private var fill = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var technique: CalmTechnique { techniques[techniqueIndex] }

    var body: some View {
        VStack(spacing: 24) {
            SessionProgressBar(count: techniques.count, current: techniqueIndex, fill: fill)
                .padding(.top, 56)
            TechniqueHeader(technique: technique)
            Spacer()
            BreathingCircle(expanded: expanded)
            Text(prompt)
                .font(ClayFont.title2.bold())
                .multilineTextAlignment(.center)
                .frame(minHeight: 90)
                .contentTransition(.opacity)
            Spacer()
            SessionControls(voiceOn: $voiceOn) { skipRequested = true }
        }
        .foregroundStyle(.white)
        .padding(24)
        .task { await play() }
        .onChange(of: voiceOn) { _, on in if !on { voice.stop() } }
        .onDisappear { voice.stop() }
    }

    private func play() async {
        for index in techniques.indices {
            withTransaction(Transaction(animation: nil)) { techniqueIndex = index; fill = 0 }
            skipRequested = false
            var done = 0.0
            let total = techniques[index].steps.reduce(0) { $0 + length($1) }
            for step in techniques[index].steps {
                let seconds = length(step)
                // Glide the bar to where this step ends, over exactly the step's length.
                done += seconds
                withAnimation(reduceMotion ? nil : .linear(duration: seconds)) { fill = done / total }
                withAnimation { prompt = step.addsOn ? prompt + "\n" + step.prompt : step.prompt }
                if voiceOn { voice.say(step.prompt) }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                if step.motion != .still {
                    withAnimation(.easeInOut(duration: seconds)) { expanded = step.motion == .expand }
                }
                if await wait(seconds) == false { return }
                if skipRequested { break }
            }
        }
        onFinish()
    }

    /// Breathing steps stretch with the user's pace setting; spoken/still steps keep their length.
    private func length(_ step: ResetStep) -> Double { step.motion == .still ? step.seconds : step.seconds * pace }

    /// Rate 8 is the built-in timing; each step down stretches breaths 20% (1 → 2.4×), up shrinks them (10 → 0.6×).
    private var pace: Double { 1 + (8 - rate) * 0.2 }

    /// Sleeps in short slices so "Skip" responds immediately. Returns false if the view went away.
    private func wait(_ seconds: Double) async -> Bool {
        var left = seconds
        while left > 0 && !skipRequested {
            try? await Task.sleep(for: .milliseconds(250))
            if Task.isCancelled { return false }
            left -= 0.25
        }
        return true
    }
}
