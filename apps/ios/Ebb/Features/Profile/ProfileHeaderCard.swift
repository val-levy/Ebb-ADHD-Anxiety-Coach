import SwiftUI

/// Avatar, name, a line about you, and quick stats. Stored on-device until the profile schema exists.
struct ProfileHeaderCard: View {
    let resets: Int, sessions: Int, badges: Int
    @AppStorage("profileName") private var name = ""
    @AppStorage("profileBio") private var bio = ""
    @AppStorage("profileAnimal") private var animal = AvatarAnimal.panda
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
            TextField("A little about you", text: $bio, axis: .vertical)
                .font(ClayFont.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).lineLimit(1...3)
            HStack {
                stat(resets, "resets")
                stat(sessions, "sessions")
                stat(badges, "badges")
            }
        }
        .padding(20)
        .clay()
        .sheet(isPresented: $picking) { AvatarPicker(selection: $animal) }
    }

    private func stat(_ n: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(n)").font(ClayFont.title3.bold())
            Text(label).font(ClayFont.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
