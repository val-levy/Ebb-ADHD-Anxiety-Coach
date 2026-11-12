import SwiftUI

/// Full-height writing space for a brain dump. The one button gives a small step, saves the dump and clears the box.
struct BrainDumpSheet: View {
    @EnvironmentObject private var dumps: BrainDumpStore
    @Environment(\.dismiss) private var dismiss
    @State private var nextStep: String?
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Unload your head").font(ClayFont.title3)
                Spacer()
                Button("Close") { dismiss() }.font(ClayFont.headline).foregroundStyle(.secondary)
            }
            TextEditor(text: $dumps.draft)
                .focused($focused)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Theme.tile, in: .rect(cornerRadius: Theme.tileRadius, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if dumps.draft.isEmpty {
                        Text("Everything that's spinning around…").foregroundStyle(.tertiary).padding(18).allowsHitTesting(false)
                    }
                }
                .frame(minHeight: 160)
            if let nextStep {
                Text(nextStep).font(ClayFont.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .clay(Theme.clayButter, radius: Theme.tileRadius + 4)
                    .foregroundStyle(.black.opacity(0.85))
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            Button {
                withAnimation(.spring) { nextStep = NextStepSuggester.suggest(from: dumps.draft) }  // step first: saving clears the draft
                focused = false
                Task { await dumps.saveDraft() }
            } label: {
                ClayLabel("Give me one small step", .sparkle)
                    .font(ClayFont.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .overlay { GrainOverlay().clipShape(.rect(cornerRadius: 22, style: .continuous)) }
                    .clay(Theme.clayTeal, radius: 22)
            }
            .disabled(dumps.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Theme.canvas.ignoresSafeArea())
        .presentationDetents([.large])
        .onAppear { focused = true }
    }
}
