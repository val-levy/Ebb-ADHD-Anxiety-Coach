import SwiftUI

/// This week's graphs, one InsightCard each. To add a graph: make a view that wraps InsightCard and list it here.
struct InsightsScreen: View {
    var body: some View {
        SceneScreen(title: "This week", tips: .reflect, mascotAt: 0.78) {
            ClayBackButton(label: "Reflect")
            ResetsPerDayChart().popIn(0)
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
        .toolbar(.hidden, for: .navigationBar)
    }
}
