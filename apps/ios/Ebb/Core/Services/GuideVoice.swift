import AVFoundation

/// Speaks session prompts aloud so the user can close their eyes. Uses the on-device system voice.
final class GuideVoice {
    private let synth = AVSpeechSynthesizer()

    init() {
        // Mix with other audio and keep speaking with the silent switch on.
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
    }

    func say(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85   // slower, calmer
        utterance.pitchMultiplier = 0.95
        synth.speak(utterance)
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
    }
}
