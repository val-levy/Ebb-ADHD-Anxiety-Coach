import SwiftUI

/// What a stress nudge looks like: a gentle offer with easy ways to say no.
struct NudgeSheet: View {
    @EnvironmentObject private var store: ResetStore
    @EnvironmentObject private var nudges: NudgeStore

    var body: some View {
        VStack(spacing: 16) {
            Text("Hey. Want a quick reset?").font(ClayFont.title2.bold())
            Text("Looks like things might be a lot right now.").foregroundStyle(.secondary)
            Button("Yes, 60 seconds") {
                nudges.accept()
                store.activeReset = store.bestReset
            }
            .buttonStyle(.borderedProminent)
            HStack(spacing: 24) {
                Button("Not now") { nudges.dismiss() }
                Button("Snooze 1 hr") { nudges.snooze() }
                Button("False alarm") { nudges.markFalseAlarm() }
            }
            .font(ClayFont.subheadline)
        }
        .padding()
        .onDisappear { nudges.dismiss() }
    }
}
