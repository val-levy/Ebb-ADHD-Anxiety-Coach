import SwiftUI

/// This week's graphs, one InsightCard each. To add a graph: make a view that wraps InsightCard and list it here.
struct InsightsScreen: View {
    var body: some View {
        SceneScreen(title: "This week", tips: .reflect, mascotAt: 0.78) {
            ClayBackButton(label: "Reflect")
            ResetsPerDayChart().popIn(0)
            CalmDropChart().popIn(1)
            SectionLabel("What helped")
            HelpedCard().popIn(2)
            SectionLabel("Patterns")
            PatternsSection()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
