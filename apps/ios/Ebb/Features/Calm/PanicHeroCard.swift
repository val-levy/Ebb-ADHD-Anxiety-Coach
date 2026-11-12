import SwiftUI

/// The one-tap entry for an active panic attack: a compact lavender clay pill with a soft round icon. Calm, no reading required.
struct PanicHeroCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ClayFace(mood: CalmProgram.panic.mood, ink: Theme.claySea, size: 54)
                    .background(.white.opacity(0.92), in: .circle)
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(CalmProgram.panic.title).font(ClayFont.title3.bold())
                    Text("I'll walk you through it · \(CalmProgram.panic.minutes) min").font(ClayFont.footnote).opacity(0.9)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").clayGlyph().font(ClayFont.system(size: 16, weight: .bold)).opacity(0.8)
            }
            .multilineTextAlignment(.leading)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .overlay { GrainOverlay().clipShape(.capsule) }
            .clay(Theme.claySea, radius: 44)
        }
        .accessibilityHint("Starts a guided session")
    }
}
