import SwiftUI

/// The three newest saved brain dumps as short previews, with a link to the full list.
struct BrainDumpHistoryCard: View {
    @EnvironmentObject private var dumps: BrainDumpStore
    private let previewCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if dumps.dumps.isEmpty {
                Text("Your brain dumps show up here after you ask for a small step.")
                    .font(ClayFont.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(dumps.dumps.prefix(previewCount)) { dump in
                    BrainDumpRow(dump: dump) { Task { await dumps.delete(dump) } }
                }
                if dumps.dumps.count > previewCount || dumps.hasMore {
                    NavigationLink { BrainDumpsScreen() } label: {
                        ClayLabel("See all", .chevronRight, size: 16)
                            .font(ClayFont.subheadline).foregroundStyle(Theme.accent)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .clay()
    }
}
