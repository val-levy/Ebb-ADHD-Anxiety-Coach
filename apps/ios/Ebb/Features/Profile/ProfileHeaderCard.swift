import SwiftUI

/// Avatar, name, a line about you, and quick stats, from your account profile.
struct ProfileHeaderCard: View {
    let resets: Int, sessions: Int, badges: Int
    @EnvironmentObject private var session: SessionStore
    @State private var name = ""
    @State private var bio = ""
    @State private var animal = AvatarAnimal.panda
    @State private var picking = false

    var body: some View {
        VStack(spacing: 14) {
            Button { picking = true } label: {
                AnimalAvatar(animal: animal, size: 96)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil.circle.fill").font(ClayFont.title2).foregroundStyle(.white, Theme.accent)
                    }
            }
            .accessibilityHint("Choose your animal")
            TextField("Your name", text: $name).font(ClayFont.title2.bold()).multilineTextAlignment(.center)
                .onSubmit(commit)
            if let u = session.profile?.username {
                Text("@\(u)").font(ClayFont.footnote).foregroundStyle(.secondary)
            }
            TextField("A little about you", text: $bio, axis: .vertical)
                .font(ClayFont.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).lineLimit(1...3)
                .onSubmit(commit)
            HStack {
                stat(resets, "resets")
                stat(sessions, "sessions")
                stat(badges, "badges")
            }
        }
        .padding(20)
        .clay()
        .sheet(isPresented: $picking, onDismiss: commit) { AvatarPicker(selection: $animal) }
        .onChange(of: session.profile, initial: true) { _, p in
            name = p?.displayName ?? ""; bio = p?.bio ?? ""; animal = p?.animal ?? .panda
        }
    }

    private func commit() {
        guard var p = session.profile else { return }
        p.displayName = String(name.trimmingCharacters(in: .whitespaces).prefix(40))
        p.bio = bio.isEmpty ? nil : String(bio.prefix(160))
        p.animal = animal
        guard !p.displayName.isEmpty, p != session.profile else { return }
        Task { await session.save(p) }
    }

    private func stat(_ n: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(n)").font(ClayFont.title3.bold())
            Text(label).font(ClayFont.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
