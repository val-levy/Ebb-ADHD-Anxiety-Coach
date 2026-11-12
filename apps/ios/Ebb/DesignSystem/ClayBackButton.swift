import SwiftUI

/// "Back to <place>" pill for pushed SceneScreens (the system navigation bar is hidden there).
struct ClayBackButton: View {
    let label: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button { dismiss() } label: {
            ClayLabel("Back to \(label)", .chevronLeft, size: 18)
                .font(ClayFont.subheadline)
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .clay(Theme.surface, radius: 20)
        }
        .accessibilityLabel("Back to \(label)")
    }
}
