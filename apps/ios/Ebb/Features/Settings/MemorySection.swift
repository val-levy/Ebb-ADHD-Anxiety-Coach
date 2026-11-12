import SwiftUI

/// "What Ebb remembers": the short note the chat keeps about you. Editable and clearable.
struct MemorySection: View {
    @EnvironmentObject private var memory: MemoryStore

    var body: some View {
        SettingsCard(title: "What Ebb remembers") {
            Text("The chat keeps a short note so you don't repeat yourself. It's yours: change it or clear it any time.")
                .font(ClayFont.footnote).foregroundStyle(.secondary)
            TextField("Nothing yet. Chat a bit and it fills in.", text: $memory.text, axis: .vertical)
                .lineLimit(3...8).font(ClayFont.body)
                .onChange(of: memory.text) { _, t in if t.count > MemoryStore.limit { memory.text = String(t.prefix(MemoryStore.limit)) } }
            HStack {
                Button("Save") { Task { await memory.save() } }.disabled(!memory.hasChanges)
                Spacer()
                Button("Clear", role: .destructive) { Task { await memory.clear() } }.disabled(memory.saved.isEmpty)
            }
            .font(ClayFont.subheadline)
        }
        .task { await memory.load() }
    }
}
