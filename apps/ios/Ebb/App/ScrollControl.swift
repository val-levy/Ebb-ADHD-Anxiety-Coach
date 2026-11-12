import SwiftUI

/// Lets a screen inside a SceneScreen read and drive its scroll position (used for auto-scroll while dragging).
@Observable final class ScrollControl {
    var position = ScrollPosition()
    @ObservationIgnored var offset: CGFloat = 0
    @ObservationIgnored var viewport: CGFloat = 0

    func scroll(by dy: CGFloat) { position.scrollTo(y: max(0, offset + dy)) }

    /// How far to scroll so a tip's spotlight sits fully on screen (clear of the title and tab bar); 0 if it already does.
    static func revealDelta(spot: CGRect, screenHeight: CGFloat) -> CGFloat {
        let top: CGFloat = 130, bottom = screenHeight - 130
        if spot.minY >= top && spot.maxY <= bottom { return 0 }
        if spot.height > bottom - top { return spot.minY - top }
        return spot.midY - (top + bottom) / 2
    }

    func reveal(_ spot: CGRect, screenHeight: CGFloat) {
        let dy = Self.revealDelta(spot: spot, screenHeight: screenHeight)
        if dy != 0 { withAnimation(.easeInOut(duration: 0.45)) { scroll(by: dy) } }
    }

    static func selfCheck() {
        assert(revealDelta(spot: CGRect(x: 0, y: 300, width: 300, height: 100), screenHeight: 800) == 0)
        assert(revealDelta(spot: CGRect(x: 0, y: 900, width: 300, height: 100), screenHeight: 800) == 550)
        assert(revealDelta(spot: CGRect(x: 0, y: 10, width: 300, height: 100), screenHeight: 800) < 0)
    }
}

extension EnvironmentValues {
    @Entry var scrollControl = ScrollControl()
}
