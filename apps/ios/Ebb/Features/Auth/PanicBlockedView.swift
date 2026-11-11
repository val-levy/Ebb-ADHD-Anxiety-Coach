import SwiftUI

/// After two anonymous panic sessions: crisis lines first, then sign in.
struct PanicBlockedView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            AnimalAvatar(animal: .panda, size: 96)
            Text("You're not alone").font(ClayFont.title)
            Text("If you need someone right now, the 988 Lifeline is free and open 24/7.")
                .font(ClayFont.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
            HStack(spacing: 12) {
                link("Call 988", "phone.fill", "tel:988")
                link("Text 988", "message.fill", "sms:988")
            }
            Text("Sign in to keep using panic help in Ebb.").font(ClayFont.subheadline).padding(.top, 8)
            Button {
                session.queuedSheet = .signIn(reason: "Sign in to keep using panic help anytime")
                dismiss()
            } label: {
                Text("Sign in").font(ClayFont.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(14).clay(Theme.accent, radius: 26)
            }
            Button("Close") { dismiss() }.font(ClayFont.headline).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(24)
        .background(Theme.canvas.ignoresSafeArea())
    }

    private func link(_ title: String, _ symbol: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) {
            Label(title, systemImage: symbol).font(ClayFont.headline).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(14).clay(Theme.clayLavender, radius: 26)
        }
    }
}
