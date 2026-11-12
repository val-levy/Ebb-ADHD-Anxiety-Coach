import SwiftUI

/// Entry row on Reflect that opens the chat.
struct ChatCard: View {
    var body: some View {
        NavigationLink { ChatScreen() } label: {
            HStack(spacing: 12) {
                ClayIconTile(symbol: "bubble.left.and.bubble.right.fill", size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chat").font(ClayFont.headline)
                    Text("Say what's on your mind. I'll jot it down.").font(ClayFont.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding().frame(maxWidth: .infinity).clay()
        }
    }
}
