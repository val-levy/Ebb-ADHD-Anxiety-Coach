import SwiftUI

/// Saved brain dumps, newest first, as short previews.
struct BrainDumpHistoryCard: View {
    @EnvironmentObject private var dumps: BrainDumpStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if dumps.dumps.isEmpty {
                Text("Your brain dumps show up here after you ask for a small step.")
                    .font(ClayFont.subheadline).foregroundStyle(.secondary)
            } else {
                ForEach(dumps.dumps) { dump in
                    BrainDumpRow(dump: dump) { Task { await dumps.delete(dump) } }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .clay()
    }
}
