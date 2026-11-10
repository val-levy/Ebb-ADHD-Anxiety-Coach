import SwiftUI

/// One-tap feedback after a reset. Skipping is always allowed.
struct ResetRatingView: View {
    let onRate: (Bool?) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Nice. Did that help?").font(ClayFont.title.bold()).foregroundStyle(.white)
            VStack(spacing: 12) {
                Button("It helped") { onRate(true) }.buttonStyle(.borderedProminent)
                Button("Not really") { onRate(false) }.buttonStyle(.bordered)
                Button("Skip") { onRate(nil) }.foregroundStyle(.white.opacity(0.8))
            }
            .tint(.white)
            .foregroundStyle(Theme.accent)
        }
    }
}
