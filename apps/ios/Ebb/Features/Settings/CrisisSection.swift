import SwiftUI

/// Always-reachable crisis line. Ebb is a wellness tool, not emergency care.
struct CrisisSection: View {
    var body: some View {
        Section {
            Link("Call 988 (Suicide & Crisis Lifeline)", destination: URL(string: "tel:988")!)
            Link("Text 988", destination: URL(string: "sms:988")!)
        } header: {
            Text("Need more help?")
        } footer: {
            Text("Ebb is a wellness tool, not emergency or medical care.")
        }
    }
}
