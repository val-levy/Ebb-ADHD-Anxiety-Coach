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
                ClayLabel(voiceOn ? "Voice on" : "Voice off", voiceOn ? .speakerOn : .speakerOff, size: 24)
            }
            Button(action: onSkip) {
                ClayLabel("Next", .next, size: 24)
            }
        }
        .font(ClayFont.headline)
        .foregroundStyle(.white.opacity(0.9))
    }
}
