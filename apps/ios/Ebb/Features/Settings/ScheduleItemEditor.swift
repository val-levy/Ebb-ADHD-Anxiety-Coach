import SwiftUI

/// Edit one time slot: its name, its time(s), and whether it's on.
struct ScheduleItemEditor: View {
    @Binding var item: ScheduleItem
    let hasEnd: Bool

    var body: some View {
        Form {
            TextField("Name", text: $item.name)
            Toggle("On", isOn: $item.on)
            DatePicker(hasEnd ? "Starts" : "Time", selection: $item.start, displayedComponents: .hourAndMinute)
            if hasEnd {
                DatePicker("Ends", selection: Binding { item.end ?? item.start } set: { item.end = $0 },
                           displayedComponents: .hourAndMinute)
            }
        }
        .clayCanvas()
        .navigationTitle(item.name)
    }
}
