import SwiftUI

/// Buttons squish and bounce back like poked clay, but only after a clean tap.
/// A primitive style driven by a tap gesture, so a swipe or scroll that starts on a card never fires it and never
/// flashes a pressed state. (The system press-highlight fires instantly on touch-down, which felt like accidental clicks.)
struct SquishyButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        SquishyButton(configuration: configuration)
    }
}
