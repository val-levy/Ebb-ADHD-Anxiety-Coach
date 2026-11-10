import SwiftUI

/// Brain dump: type (or dictate) everything spinning around, then get one small next step.
struct BrainDumpCard: View {
    @AppStorage("dump") private var dump = ""   // ponytail: local only; move to Supabase once the feature is kept
    @State private var nextStep: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ClayIconTile(symbol: "tray.and.arrow.down.fill")
                VStack(alignment: .leading) {
                    Text("Unload your head").font(ClayFont.headline)
                    Text("Tap the mic on the keyboard to dictate.").font(ClayFont.footnote).foregroundStyle(.secondary)
                }
            }
            TextEditor(text: $dump)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 140)
                .padding(10)
                .background(Theme.tile, in: .rect(cornerRadius: Theme.tileRadius, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if dump.isEmpty {
                        Text("Everything that's spinning around…").foregroundStyle(.tertiary).padding(18).allowsHitTesting(false)
                    }
                }
            Button { withAnimation(.spring) { nextStep = NextStepSuggester.suggest(from: dump) } } label: {
                Label("Give me one small step", systemImage: "sparkles")
                    .font(ClayFont.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .overlay { GrainOverlay().clipShape(.rect(cornerRadius: 22, style: .continuous)) }
                    .clay(Theme.clayTeal, radius: 22)
            }
            if let nextStep {
                Text(nextStep).font(ClayFont.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .clay(Theme.clayButter, radius: Theme.tileRadius + 4)
                    .foregroundStyle(.black.opacity(0.85))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .padding()
        .clay()
    }
}
