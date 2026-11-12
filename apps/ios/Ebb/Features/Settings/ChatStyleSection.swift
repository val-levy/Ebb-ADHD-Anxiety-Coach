import SwiftUI

/// "How the chat talks to you": optional tone and style notes. They never change what the chat will or won't do.
struct ChatStyleSection: View {
    @EnvironmentObject private var style: ChatStyleStore

    var body: some View {
        SettingsCard(title: "How the chat talks") {
            Text("Optional. Tell the chat how you like to be talked to, like \"gentle and brief\" or \"a bit more playful\". It only changes tone and wording, never what the chat will or won't help with.")
                .font(ClayFont.footnote).foregroundStyle(.secondary)
            TextField("e.g. Keep it short and a little warm.", text: $style.text, axis: .vertical)
                .lineLimit(2...5).font(ClayFont.body)
                .onChange(of: style.text) { _, t in if t.count > ChatStyleStore.limit { style.text = String(t.prefix(ChatStyleStore.limit)) } }
            if style.willBeIgnored {
                Text("This note mentions things the chat's own rules cover, so it won't be used. Try describing tone only.")
                    .font(ClayFont.footnote).foregroundStyle(.secondary)
            }
            HStack {
                Button("Save") { Task { await style.save() } }.disabled(!style.hasChanges)
                Spacer()
                Button("Clear", role: .destructive) { Task { await style.clear() } }.disabled(style.saved.isEmpty)
            }
            .font(ClayFont.subheadline)
        }
        .task { await style.load() }
    }
}
