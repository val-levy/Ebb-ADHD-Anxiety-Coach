import SwiftUI

/// A count, not a flag, so pushing one locked screen from another never unlocks mid-transition.
/// Controls that drag sideways (e.g. the pace slider while held) turn off the app-wide tab swipe.
extension EnvironmentValues {
    @Entry var tabSwipeLocks: Binding<Int> = .constant(0)
}

extension View {
    /// Turns the app-wide tab swipe off while this screen is on screen.
    func locksTabSwipe() -> some View {
        modifier(TabSwipeLocker())
    }
}

private struct TabSwipeLocker: ViewModifier {
    @Environment(\.tabSwipeLocks) private var locks
    func body(content: Content) -> some View {
        content.onAppear { locks.wrappedValue += 1 }.onDisappear { locks.wrappedValue -= 1 }
    }
}
