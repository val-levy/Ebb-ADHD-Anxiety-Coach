import SwiftUI

/// Profile tab: who you are, your friends, and what you've earned. Settings live behind the gear.
struct ProfileView: View {
    @EnvironmentObject private var resets: ResetStore
    @EnvironmentObject private var calm: CalmStore
    @State private var showingSettings = false
    @Environment(\.isActivePage) private var isActive

    private var achievements: [Achievement] {
        Achievement.all(resets: resets.week.count, sessions: calm.history.count, helped: resets.helpedCount)
    }

    var body: some View {
        NavigationStack {
            SceneScreen(title: "Profile", tips: .profile, mascotAt: 0.66) {
                ProfileHeaderCard(resets: resets.week.count, sessions: calm.history.count,
                                  badges: achievements.filter(\.earned).count)
                    .overlay(alignment: .topTrailing) {
                        Button { showingSettings = true } label: {
                            Image(systemName: "gearshape.fill").font(ClayFont.title2).foregroundStyle(.secondary).padding(16)
                        }
                        .accessibilityLabel("Settings")
                    }
                    .mascotTip(.avatar)
                    .floating().popIn(0)

                SectionLabel("Friends")
                FriendsCard().mascotTip(.friends).popIn(1)

                SectionLabel("Achievements")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(achievements.enumerated()), id: \.element.id) { i, a in
                        AchievementTile(achievement: a).popIn(i + 2)
                    }
                }
                .mascotTip(.achievements)
            }
            .navigationDestination(isPresented: $showingSettings) { SettingsView() }
        }
        // Leaving the tab closes Settings, so coming back always lands on Profile.
        .onChange(of: isActive) { _, active in if !active { showingSettings = false } }
    }
}
