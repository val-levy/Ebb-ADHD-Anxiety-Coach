import AuthenticationServices
import SwiftUI

/// Clay sign-in card with the Apple button.
struct SignInSheet: View {
    let reason: String
    var onSkip: (() -> Void)? = nil
    @EnvironmentObject private var session: SessionStore
    @State private var nonce = AppleNonce.make()

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)
            AnimalAvatar(animal: .panda, size: 96)
            Text("Sign in to Ebb").font(ClayFont.title2)
            Text(reason).font(ClayFont.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
            if let msg = session.signInMessage {
                Text(msg).font(ClayFont.footnote).foregroundStyle(Theme.clayOrange).multilineTextAlignment(.center)
            }
            SignInWithAppleButton(.signIn) { req in
                nonce = AppleNonce.make()
                req.requestedScopes = [.fullName]
                req.nonce = nonce.hashed
            } onCompletion: { result in
                Task { await session.completeApple(result, rawNonce: nonce.raw) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(Capsule())
            EmailSignInFields()
            if let onSkip {
                Button("Not now", action: onSkip).font(ClayFont.headline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clayCanvas()
        .presentationDetents([.fraction(0.72)])
        .presentationDragIndicator(.visible)
    }
}
