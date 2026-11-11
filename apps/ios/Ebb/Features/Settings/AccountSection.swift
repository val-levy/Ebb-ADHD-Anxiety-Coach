import SwiftUI

/// Account controls: sign in for anonymous users; username, sign out, and delete for signed-in profiles.
struct AccountSection: View {
    @EnvironmentObject private var session: SessionStore
    @State private var confirmDelete = false
    @State private var finalDelete = false
    @State private var deleteFailed = false

    var body: some View {
        SettingsCard(title: "Account") {
            if let p = session.profile {
                LabeledContent("Signed in as", value: "@\(p.username)")
                Button("Sign out") { Task { await session.signOut() } }
                Button("Delete account", role: .destructive) { confirmDelete = true }
            } else {
                Button {
                    session.sheet = session.authSheet(reason: "Sign in to save your resets and keep what helps.")
                } label: {
                    Label("Sign in with Apple", systemImage: "apple.logo")
                }
            }
        }
        .confirmationDialog("Delete your Ebb account?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete account", role: .destructive) { finalDelete = true }
        }
        .alert("This deletes everything", isPresented: $finalDelete) {
            Button("Delete forever", role: .destructive) {
                Task { deleteFailed = !(await session.deleteAccount()) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your profile, resets, sessions and history are removed for good. This can't be undone.")
        }
        .alert("Couldn't delete your account. Check your connection and try again.", isPresented: $deleteFailed) {}
    }
}
