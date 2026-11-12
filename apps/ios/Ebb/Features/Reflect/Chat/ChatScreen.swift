import SwiftUI

/// Talk it out. Ebb listens and quietly logs doses, stressors and brain dumps you mention.
struct ChatScreen: View {
    @EnvironmentObject private var chat: ChatStore
    @State private var draft = ""

    var body: some View {
        SceneScreen(title: "Chat", tips: .reflect, mascotAt: 0.78) {
            ClayBackButton(label: "Reflect")
            LazyVStack(spacing: 10) {
                if chat.messages.isEmpty {
                    Text("Tell me how it's going. I'll keep a note of what you mention.")
                        .font(ClayFont.body).foregroundStyle(.secondary).padding(.vertical, 8)
                }
                ForEach(chat.messages) { ChatBubble(message: $0) }
                if chat.isSending { ProgressView().frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 14) }
                if chat.failed { Text("That didn't go through. Try again?").font(ClayFont.footnote).foregroundStyle(.secondary) }
            }
            HStack(spacing: 10) {
                TextField("Say anything…", text: $draft, axis: .vertical).lineLimit(1...4)
                    .padding(12).clay(Theme.surface, radius: 20)
                Button { let t = draft; draft = ""; Task { await chat.send(t) } } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 34)).foregroundStyle(Theme.accent)
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || chat.isSending)
                .accessibilityLabel("Send")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await chat.load() }
    }
}
