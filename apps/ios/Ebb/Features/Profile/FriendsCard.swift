import SwiftUI

/// Friends. Invites work today via the share sheet; the friend list arrives with the profile schema.
struct FriendsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ClayIconTile(symbol: "person.2.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("No friends yet").font(ClayFont.headline)
                    Text("Calm is easier together.").font(ClayFont.subheadline).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            ShareLink(item: "Come breathe with me on Ebb 🌿") {
                Label("Invite a friend", systemImage: "plus")
                    .font(ClayFont.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .foregroundStyle(.white).background(Theme.accent, in: Capsule())
            }
        }
        .padding()
        .clay()
    }
}
