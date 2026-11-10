import SwiftUI

/// What a stress nudge looks like: a gentle offer with easy ways to say no.
struct NudgeSheet: View {
    @EnvironmentObject private var store: ResetStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Hey. Want a quick reset?").font(ClayFont.title2.bold())
            Text("Looks like things might be a lot right now.").foregroundStyle(.secondary)
            Button("Yes, 60 seconds") {
                dismiss()
                store.activeReset = store.bestReset
            }
            .buttonStyle(.borderedProminent)
            HStack(spacing: 24) {
                Button("Not now") { dismiss() }
                Button("Snooze 1 hr") { dismiss() }
                Button("False alarm") { dismiss() } // ponytail: not stored yet; will lower future nudges once detection exists
            }
            .font(ClayFont.subheadline)
        }
        .padding()
    }
}
