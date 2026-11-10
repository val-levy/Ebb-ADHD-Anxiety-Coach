import SwiftUI

/// Pages in the pager stay alive side by side, so onAppear/onDisappear never fire on a tab switch.
/// Screens watch this instead to know when they're the one on screen.
extension EnvironmentValues {
    @Entry var isActivePage = true
}
