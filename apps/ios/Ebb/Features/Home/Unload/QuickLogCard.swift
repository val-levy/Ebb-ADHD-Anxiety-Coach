import SwiftUI

/// One-tap logging: a dose button and a stressor chip row. Just a record for your own patterns, never a reminder.
struct QuickLogCard: View {
    @EnvironmentObject private var logs: LogStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ClayIconTile(symbol: "square.and.pencil", size: 40)
                Text("Log something").font(ClayFont.headline)
            }
            Button { Task { await logs.logDose() } } label: {
                ClayLabel("Log a dose", .pill, tint: Theme.clayOrange).font(ClayFont.body)
                    .frame(maxWidth: .infinity).padding(.vertical, 12).background(Theme.tile, in: .capsule)
            }
            Text("Something weighing on you?").font(ClayFont.footnote).foregroundStyle(.secondary)
            StressorChips()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding().clay()
    }
}
