import SwiftUI

/// Always-reachable crisis line. Ebb is a wellness tool, not emergency care.
struct CrisisSection: View {
    var body: some View {
        SettingsCard(title: "Need more help?") {
            Link("Call 988 (Suicide & Crisis Lifeline)", destination: URL(string: "tel:988")!)
            Link("Text 988", destination: URL(string: "sms:988")!)
            Text("Ebb is a wellness tool, not emergency or medical care.").font(ClayFont.footnote).foregroundStyle(.secondary)
        }
    }
}
