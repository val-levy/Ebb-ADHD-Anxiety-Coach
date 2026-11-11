import SwiftUI

/// One saved dump: date and a two-line preview. Tap to read it all.
struct BrainDumpRow: View {
    let dump: BrainDump
    let onDelete: () -> Void
    @State private var expanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { withAnimation(.spring) { expanded.toggle() } } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dump.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(ClayFont.caption).foregroundStyle(.secondary)
                    Text(dump.body)
                        .font(ClayFont.subheadline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(expanded ? nil : 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityHint(expanded ? "Collapse" : "Read all")
            Button(role: .destructive, action: onDelete) { Image(systemName: "trash") }
                .font(ClayFont.subheadline).foregroundStyle(.secondary)
                .accessibilityLabel("Delete brain dump")
        }
    }
}
