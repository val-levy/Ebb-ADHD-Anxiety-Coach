import SwiftUI

/// Small uppercase, letter-spaced gray label above a group of rows.
struct SectionLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(ClayFont.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}
