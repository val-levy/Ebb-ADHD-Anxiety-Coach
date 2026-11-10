import SwiftUI

/// Shows the user, in their own numbers, that it passes. Helps break future fear-of-fear.
struct CalmProgressCard: View {
    let before: Double
    let after: Double
    let sessions: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("It passes").font(ClayFont.headline)
            Text("Across your sessions, intensity went from **\(before, specifier: "%.0f")** to **\(after, specifier: "%.0f")** out of 10 on average.")
            Text("\(sessions) sessions so far").font(ClayFont.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .clay()
    }
}
