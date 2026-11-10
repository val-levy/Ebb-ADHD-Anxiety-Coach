import SwiftUI

/// Where the Quick/Guided card grid sits on screen (global coordinates). Swipes that start inside it flip
/// Quick ⇄ Guided; swipes anywhere else on Calm move between tabs.
extension EnvironmentValues {
    @Entry var calmModeArea: Binding<CGRect> = .constant(.zero)
}
