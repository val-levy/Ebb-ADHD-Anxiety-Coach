import SwiftUI

/// Technique name plus a one-line "why this works", so the user learns the skill, not just follows it.
struct TechniqueHeader: View {
    let technique: CalmTechnique

    var body: some View {
        VStack(spacing: 6) {
            Label { Text(technique.title) } icon: { ClayFace(mood: .forSymbol(technique.symbol), ink: .white.opacity(0.85), size: 30) }.font(ClayFont.headline)
            Text(technique.why)
                .font(ClayFont.footnote)
                .multilineTextAlignment(.center)
                .opacity(0.8)
        }
        .id(technique) // fade between techniques
        .transition(.opacity)
    }
}
