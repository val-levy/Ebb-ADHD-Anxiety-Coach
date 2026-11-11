import SwiftUI

/// What helped and patterns, one tap away from Reflect.
struct InsightsScreen: View {
    var body: some View {
        SceneScreen(title: "This week", tips: .reflect, mascotAt: 0.78) {
            ClayBackButton(label: "Reflect")
            SectionLabel("What helped")
            HelpedCard().popIn(0)
            SectionLabel("Patterns")
            PatternsSection()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
