import SwiftUI

/// A grouped settings surface that keeps controls in the same clay visual language as the rest of Ebb.
struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title)
            content
        }
        .padding(16)
        .clay()
    }
}
