import SwiftUI

/// One message: yours on the right in the accent color, Ebb's on the left in a clay card.
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            Text(message.body).font(ClayFont.body)
                .foregroundStyle(message.isUser ? Color.white : Color.primary)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(message.isUser ? Theme.accent : Theme.surface, in: RoundedRectangle(cornerRadius: 20))
            if !message.isUser { Spacer(minLength: 40) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.isUser ? "You" : "Ebb"): \(message.body)")
    }
}
