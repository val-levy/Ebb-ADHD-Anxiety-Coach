import SwiftUI

/// Compact entry point for a brain dump: one pill that opens the writing sheet.
struct BrainDumpCard: View {
    @EnvironmentObject private var dumps: BrainDumpStore
    @State private var writing = false

    var body: some View {
        Button { writing = true } label: {
            HStack(spacing: 12) {
                ClayIconTile(symbol: "cloud.fill", size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(dumps.draft.isEmpty ? "What's on your mind?" : "Pick up where you left off").font(ClayFont.headline)
                    Text(dumps.draft.isEmpty ? "Unload your head, then get one small step." : dumps.draft)
                        .font(ClayFont.footnote).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                ClayIcon(kind: .chat, size: 26).foregroundStyle(Theme.clayTeal)
            }
            .padding(14)
            .clay()
        }
        .sheet(isPresented: $writing) { BrainDumpSheet() }
    }
}
