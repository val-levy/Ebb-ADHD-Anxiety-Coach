import SwiftUI

/// Lets a screen inside a SceneScreen read and drive its scroll position (used for auto-scroll while dragging).
@Observable final class ScrollControl {
    var position = ScrollPosition()
    @ObservationIgnored var offset: CGFloat = 0
    @ObservationIgnored var viewport: CGFloat = 0

    func scroll(by dy: CGFloat) { position.scrollTo(y: max(0, offset + dy)) }
}

extension EnvironmentValues {
    @Entry var scrollControl = ScrollControl()
}
