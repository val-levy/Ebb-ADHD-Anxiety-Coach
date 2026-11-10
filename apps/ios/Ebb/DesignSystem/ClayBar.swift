import SwiftUI

/// A small clay progress bar: a pale track with a soft colored lump filled to `fraction` (0...1).
struct ClayBar: View {
    let fraction: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            Capsule().fill(Theme.tile)
                .overlay(alignment: .leading) {
                    Color.clear.frame(width: max(10, geo.size.width * fraction)).clay(color, radius: 5)
                }
        }
        .frame(height: 10)
        .accessibilityHidden(true)
    }
}
