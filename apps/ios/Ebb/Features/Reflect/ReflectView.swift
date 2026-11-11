import SwiftUI

/// Reflect tab (merged Insights + Unload): empty your head, get one small step, then see what's been helping.
struct ReflectView: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        NavigationStack {
            SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
                BrainDumpCard().lockedUntilSignIn("Sign in to save brain dumps").mascotTip(.brainDump).floating().popIn(0)

                SectionLabel("Past brain dumps")
                BrainDumpHistoryCard().lockedUntilSignIn("Sign in to save brain dumps").mascotTip(.pastDumps).popIn(1)

                SectionLabel("What helped this week")
                HelpedCard().mascotTip(.helped).popIn(2)

                SectionLabel("Patterns")
                if store.weeklyInsights.isEmpty {
                    Text("A few resets this week will give Ebb something gentle to reflect back.")
                        .font(ClayFont.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                        .clay()
                        .mascotTip(.patterns)
                        .popIn(3)
                } else {
                    ForEach(Array(store.weeklyInsights.enumerated()), id: \.element.id) { index, insight in
                        PatternRow(symbol: insight.symbol, text: insight.text)
                            .popIn(index + 3)
                    }
                    .mascotTip(.patterns)
                }
            }
        }
    }
}
