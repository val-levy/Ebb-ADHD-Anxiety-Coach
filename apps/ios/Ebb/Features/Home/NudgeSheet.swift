import SwiftUI

/// What a stress nudge looks like: a gentle offer with easy ways to say no.
struct NudgeSheet: View {
    @EnvironmentObject private var store: ResetStore
    @EnvironmentObject private var nudges: NudgeStore

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 12)

            VStack(spacing: 14) {
                ClayFace(mood: .puff, ink: .white.opacity(0.9), size: 62)
                    .frame(width: 82, height: 82)
                    .background(Circle().fill(Theme.claySea))
                    .overlay(GrainOverlay(opacity: 0.14).clipShape(Circle()))

                Text("Want a small pause?")
                    .font(ClayFont.title2)
                Text("No pressure. A minute of breathing might help make a little room.")
                    .font(ClayFont.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .clay(Theme.tile, radius: Theme.heroRadius)

            Button {
                nudges.accept()
                store.activeReset = store.bestReset
            } label: {
                ClayLabel("Start a 60-second reset", .play)
                    .font(ClayFont.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
            }
            .foregroundStyle(.white)
            .clay(Theme.clayTeal, radius: Theme.cardRadius)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                action("Not now", icon: .close) { nudges.dismiss() }
                action("Snooze", icon: .clock) { nudges.snooze() }
                action("False alarm", icon: .check) { nudges.markFalseAlarm() }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clayCanvas()
        .onDisappear { nudges.dismiss() }
    }

    private func action(_ title: String, icon: ClayIconKind, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            VStack(spacing: 7) {
                ClayIcon(kind: icon, size: 22)
                Text(title).font(ClayFont.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .clay(Theme.surface, radius: Theme.tileRadius)
        }
    }
}
