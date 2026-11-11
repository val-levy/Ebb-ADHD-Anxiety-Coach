import SwiftUI

/// Email + password sign-in (new emails get an account, existing ones sign in).
struct EmailSignInFields: View {
    @EnvironmentObject private var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var busy = false

    var body: some View {
        VStack(spacing: 10) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress).keyboardType(.emailAddress)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding(14).clay()
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding(14).clay()
            Button(busy ? "Signing in…" : "Continue with email") {
                busy = true
                Task { await session.completeEmail(email, password: password); busy = false }
            }
            .font(ClayFont.headline)
            .disabled(busy || email.isEmpty || password.count < 6)
            Button("Forgot password?") { Task { await session.sendPasswordReset(email: email) } }
                .font(ClayFont.footnote).foregroundStyle(.secondary)
        }
        .font(ClayFont.body)
    }
}
