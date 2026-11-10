import SwiftUI

/// Puts a screen on the warm cream canvas (hides the default list/scroll background).
struct ClayCanvas: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollContentBackground(.hidden).background(Theme.canvas)
    }
}

extension View {
    func clayCanvas() -> some View { modifier(ClayCanvas()) }
}
