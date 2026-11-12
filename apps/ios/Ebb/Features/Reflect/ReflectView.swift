import SwiftUI

/// Reflect tab: this week's graphs, what helped, and patterns. To add a graph: make a view that wraps InsightCard and list it here.
struct ReflectView: View {
    var body: some View {
        SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
            ResetsPerDayChart().mascotTip(.helped).popIn(0)
            CalmDropChart().popIn(1)
            TimeOfDayChart().popIn(2)
            StressorsChart().popIn(3)
            MedicationLogChart().popIn(4)
            MedVsStressorsCard().popIn(5)
            SectionLabel("What helped")
            HelpedCard().popIn(6)
            SectionLabel("Patterns")
            PatternsSection()
        }
    }
}
