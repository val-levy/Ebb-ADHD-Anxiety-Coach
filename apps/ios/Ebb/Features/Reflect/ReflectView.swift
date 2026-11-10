import SwiftUI

/// Reflect tab (merged Insights + Unload): empty your head, get one small step, then see what's been helping.
struct ReflectView: View {
    @EnvironmentObject private var store: ResetStore

    var body: some View {
        NavigationStack {
            SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
                BrainDumpCard().mascotTip(.brainDump).floating().popIn(0)

                SectionLabel("What helped this week")
                HelpedCard().mascotTip(.helped).popIn(1)

                SectionLabel("Patterns")
                // Demo copy: shows what the weekly insight will look like once timing data exists.
                PatternRow(symbol: "calendar", text: "Sample: Resets cluster on Tuesday afternoons").mascotTip(.patterns).popIn(2)
                PatternRow(symbol: "clock.fill", text: "Sample: Breathing helped 4 of 5 times after 3pm").popIn(3)
            }
        }
    }
}
