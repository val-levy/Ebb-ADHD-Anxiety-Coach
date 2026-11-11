import SwiftUI

/// A settings list of time slots you can add, edit, toggle, and swipe to remove.
struct ScheduleSection: View {
    let title: String
    let footer: String
    let newName: String
    let hasEnd: Bool
    @Binding var items: [ScheduleItem]

    var body: some View {
        SettingsCard(title: title) {
            ForEach($items) { $item in
                NavigationLink { ScheduleItemEditor(item: $item, hasEnd: hasEnd) } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name).opacity(item.on ? 1 : 0.45)
                        Text(times(item)).font(ClayFont.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contextMenu {
                    Button("Remove", systemImage: "trash", role: .destructive) { items.removeAll { $0.id == item.id } }
                }
            }
            Button("Add", systemImage: "plus.circle.fill") {
                items.append(ScheduleItem(name: newName, start: ScheduleItem.at(9), end: hasEnd ? ScheduleItem.at(10) : nil))
            }
            Text(footer).font(ClayFont.footnote).foregroundStyle(.secondary)
        }
    }

    private func times(_ item: ScheduleItem) -> String {
        let start = item.start.formatted(date: .omitted, time: .shortened)
        let range = item.end.map { "\(start) – \($0.formatted(date: .omitted, time: .shortened))" } ?? start
        return item.on ? range : "\(range) · off"
    }
}
