import SwiftUI

/// Screen title as chunky white clay letters: a hard offset shadow gives the extruded, squished-dough edge,
/// a soft one lifts it off the sky.
struct ClayTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(ClayFont.system(size: 44, weight: .black))
            .foregroundStyle(.white)
            .shadow(color: Theme.tree.opacity(0.55), radius: 0, x: 0, y: 4)
            .shadow(color: .black.opacity(0.18), radius: 8, y: 6)
            .accessibilityAddTraits(.isHeader)
    }
}
