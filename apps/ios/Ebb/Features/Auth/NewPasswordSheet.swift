import SwiftUI

/// Shown after opening a password-reset link.
struct NewPasswordSheet: View {
    @EnvironmentObject private var session: SessionStore
    @State private var password = ""
    @State private var failed = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)
            AnimalAvatar(animal: .panda, size: 96)
            Text("Choose a new password").font(ClayFont.title2)
            SecureField("New password (6+ characters)", text: $password)
                .textContentType(.newPassword)
                .padding(14).clay()
            if failed {
                Text("Couldn't save that. Try a different password.").font(ClayFont.footnote).foregroundStyle(Theme.clayOrange)
            }
            Button("Save password") { Task { failed = !(await session.setNewPassword(password)) } }
                .font(ClayFont.headline)
                .disabled(password.count < 6)
            Spacer(minLength: 12)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clayCanvas()
        .presentationDetents([.fraction(0.6)])
    }
}
