import SwiftUI

/// Voice on/off and skip-to-next-technique.
struct SessionControls: View {
    @Binding var voiceOn: Bool
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Button {
                voiceOn.toggle()
            } label: {
                Label(voiceOn ? "Voice on" : "Voice off", systemImage: voiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
            }
            Button(action: onSkip) {
                Label("Next", systemImage: "forward.end.fill")
            }
        }
        .font(ClayFont.headline)
        .foregroundStyle(.white.opacity(0.9))
    }
}
