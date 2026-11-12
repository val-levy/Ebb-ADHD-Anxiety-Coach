import SwiftUI

/// Settings: breathing pace, guard windows, planned nudges, medications. Schedules are saved; nothing fires them yet.
struct SettingsView: View {
    @AppStorage("guardWindows") private var guards = ScheduleItem.defaultGuards
    @AppStorage("nudgePlan") private var nudges = ScheduleItem.defaultNudges
    @AppStorage("medications") private var medications: [ScheduleItem] = []
    @AppStorage("breathRate") private var breathRate = 8.0
    @EnvironmentObject private var nudgesStore: NudgeStore
    @Environment(\.tabSwipeLocks) private var swipeLocks

    var body: some View {
        SceneScreen(title: "Settings", tips: .profile, mascotAt: 0.66) {
                ClayBackButton(label: "Profile")
                SettingsCard(title: "Breathing") {
                    VStack(alignment: .leading) {
                        Text("Breathing pace · \(Int(breathRate))").font(ClayFont.subheadline)
                        Slider(value: $breathRate, in: 1...10, step: 1) {
                            Text("Breathing pace")
                        } minimumValueLabel: { Text("Slow") } maximumValueLabel: { Text("Fast") } onEditingChanged: { swipeLocks.wrappedValue += $0 ? 1 : -1 }
                    }
                    Text("How fast guided breathing goes. 8 is the standard pace.").font(ClayFont.footnote).foregroundStyle(.secondary)
                }
                ScheduleSection(title: "Guard windows", footer: "Ebb watches more closely during these hours. Needs an Apple Watch or Bluetooth heart-rate sensor (coming later).",
                                newName: "New window", hasEnd: true, items: $guards)
                ScheduleSection(title: "Planned nudges", footer: "Times Ebb checks in with you.",
                                newName: "Check-in", hasEnd: false, items: $nudges)
                SettingsCard(title: "Check-ins") {
                    Stepper("At most \(nudgesStore.nudgeCap) a day", value: nudgesStore.capBinding, in: 1...6)
                    Toggle("Pause for today", isOn: nudgesStore.pauseBinding)
                }
                ScheduleSection(title: "Medication", footer: "Add what you take and when. Stimulants shift your baseline, so Ebb will learn your on- and off-medication patterns.",
                                newName: "Medication", hasEnd: false, items: $medications)
                MemorySection()
                ChatStyleSection()
                AccountSection()
                CrisisSection()
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await nudgesStore.updatePlan(nudges) }
            .onChange(of: nudges) { _, plan in
                Task { await nudgesStore.updatePlan(plan) }
            }
    }
}
