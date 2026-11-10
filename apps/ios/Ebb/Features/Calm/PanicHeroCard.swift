import SwiftUI

/// The one-tap entry for an active panic attack. Big, calm, no reading required.
struct PanicHeroCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "hand.raised.fill").font(.system(size: 44))
                Text(CalmProgram.panic.title).font(ClayFont.largeTitle.bold())
                Text("I'll walk you through it, step by step. About \(CalmProgram.panic.minutes) minutes.").opacity(0.85)
            }
            .multilineTextAlignment(.leading)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.heroRadius)) }
            .clay(Theme.clayLavender, radius: Theme.heroRadius)
        }
        .accessibilityHint("Starts a guided session")
    }
}
