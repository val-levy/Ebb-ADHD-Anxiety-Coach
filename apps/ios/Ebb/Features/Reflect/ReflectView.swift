import SwiftUI

/// Reflect tab: write a brain dump, reread past ones, and step into this week's insights.
struct ReflectView: View {
    var body: some View {
        NavigationStack {
            SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
                BrainDumpCard().lockedUntilSignIn("Sign in to save brain dumps").mascotTip(.brainDump).floating().popIn(0)

                SectionLabel("Past brain dumps")
                BrainDumpHistoryCard().lockedUntilSignIn("Sign in to save brain dumps").mascotTip(.pastDumps).popIn(1)

                WeekSummaryCard().mascotTip(.helped).popIn(2)
            }
        }
    }
}
