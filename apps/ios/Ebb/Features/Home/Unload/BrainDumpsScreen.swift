import SwiftUI

/// Every saved brain dump, loaded a page at a time as you scroll.
struct BrainDumpsScreen: View {
    @EnvironmentObject private var dumps: BrainDumpStore

    var body: some View {
        SceneScreen(title: "Brain dumps", tips: .reflect, mascotAt: 0.78) {
            ClayBackButton(label: "Calm")
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(dumps.dumps) { dump in
                    BrainDumpRow(dump: dump) { Task { await dumps.delete(dump) } }
                        .padding().frame(maxWidth: .infinity, alignment: .leading).clay()
                        .onAppear { if dump.id == dumps.dumps.last?.id { Task { await dumps.loadMore() } } }
                }
                if dumps.hasMore { ProgressView().frame(maxWidth: .infinity) }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
