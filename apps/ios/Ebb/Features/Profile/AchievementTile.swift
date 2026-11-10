import SwiftUI

/// One badge. Locked ones are dimmed with a lock, never hidden, so there's always something to aim for.
struct AchievementTile: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            ClayIconTile(symbol: achievement.earned ? achievement.symbol : "lock.fill")
            Text(achievement.title).font(ClayFont.subheadline.bold())
            Text(achievement.detail).font(ClayFont.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(14)
        .clay()
        .opacity(achievement.earned ? 1 : 0.55)
        .accessibilityElement(children: .combine)
        .accessibilityValue(achievement.earned ? "Earned" : "Locked")
    }
}
