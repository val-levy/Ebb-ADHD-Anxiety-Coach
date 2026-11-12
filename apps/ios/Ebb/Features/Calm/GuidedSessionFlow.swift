import SwiftUI

/// Runs one session end to end: intensity check → guided techniques → intensity check → what helped.
struct GuidedSessionFlow: View {
    enum Stage { case before, guiding, after, helped }

    let program: CalmProgram
    @EnvironmentObject private var calm: CalmStore
    @Environment(\.dismiss) private var dismiss
    @State private var stage = Stage.before
    @State private var before = 7
    @State private var after = 5
    @State private var techniques: [CalmTechnique] = []

    var body: some View {
        ZStack {
            Theme.calmGradient.ignoresSafeArea()
            switch stage {
            case .before:
                IntensityCheckView(title: "How intense is it right now?", value: $before,
                                   actionTitle: "Start") { stage = .guiding }
            case .guiding:
                GuidedSessionPlayer(techniques: techniques) { stage = .after }
            case .after:
                IntensityCheckView(title: "How intense is it now?", value: $after,
                                   actionTitle: "Next") { stage = .helped }
            case .helped:
                HelpedPickerView(techniques: techniques, onPick: finish)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Close", systemImage: "xmark") { dismiss() }
                .labelStyle(.iconOnly).clayGlyph().font(ClayFont.title2).foregroundStyle(.white.opacity(0.8)).padding()
        }
        .overlay(alignment: .bottomTrailing) { MascotPeek(size: 64).clipped().padding(.trailing, 24) .ignoresSafeArea(edges: .bottom) }
        .overlay(alignment: .topLeading) {
            Button("Back", systemImage: "chevron.left", action: back)
                .labelStyle(.iconOnly).clayGlyph().font(ClayFont.title2).foregroundStyle(.white.opacity(0.8)).padding()
        }
        .onAppear { techniques = program.techniques(favorite: calm.favoriteTechnique) }
    }

    /// One stage back; from the first stage, leave the session.
    private func back() {
        switch stage {
        case .before: dismiss()
        case .guiding: stage = .before
        case .after: stage = .guiding
        case .helped: stage = .after
        }
    }

    private func finish(_ helped: CalmTechnique?) {
        let session = CalmSession(program: program, intensity_before: before, intensity_after: after, helped_technique: helped)
        Task { await calm.record(session) }
        dismiss()
    }
}
