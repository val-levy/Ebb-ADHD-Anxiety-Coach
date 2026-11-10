import SwiftUI

/// Full-screen reset player: plays the reset's steps, then asks for an optional rating.
struct ResetView: View {
    let reset: Reset

    @EnvironmentObject private var store: ResetStore
    @Environment(\.dismiss) private var dismiss
    @State private var prompt = ""
    @State private var expanded = false
    @State private var isFinished = false

    var body: some View {
        ZStack {
            Theme.calmGradient.ignoresSafeArea()
            VStack(spacing: 40) {
                Text(reset.title).font(ClayFont.headline).foregroundStyle(.white.opacity(0.8))
                Spacer()
                if isFinished {
                    ResetRatingView(onRate: finish)
                } else {
                    BreathingCircle(expanded: expanded)
                    Text(prompt).font(ClayFont.title2.bold()).foregroundStyle(.white).multilineTextAlignment(.center)
                }
                Spacer()
                if !isFinished {
                    Button("End early") { isFinished = true }.foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .overlay(alignment: .bottomLeading) { MascotPeek(size: 64).clipped().padding(.leading, 24).ignoresSafeArea(edges: .bottom) }
        .task { await play() }
    }

    private func play() async {
        for step in reset.steps {
            withAnimation { prompt = step.prompt }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred() // eyes-free cue
            withAnimation(.easeInOut(duration: step.seconds)) { expanded = step.motion == .expand }
            try? await Task.sleep(for: .seconds(step.seconds))
            if Task.isCancelled || isFinished { return }
        }
        withAnimation { isFinished = true }
    }

    private func finish(_ helped: Bool?) {
        Task { await store.record(reset, helped: helped) }
        dismiss()
    }
}
