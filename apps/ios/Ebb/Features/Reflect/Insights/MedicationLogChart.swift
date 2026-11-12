import SwiftUI

/// Which of the last seven days have a logged dose. A plain record, not a goal: empty days are just empty.
struct MedicationLogChart: View {
    @EnvironmentObject private var logs: LogStore

    var body: some View {
        let days = DailyCount.make(from: [])
        let logged = logs.doseDays
        let n = days.filter { logged.contains($0.day) }.count
        InsightCard(symbol: "pills.fill", title: "Medication log",
                    headline: n == 0 ? "Doses you log will show up here." : "Logged on \(n) of the last 7 days") {
            HStack {
                ForEach(days) { d in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(logged.contains(d.day) ? Theme.clayTeal : Theme.clayTeal.opacity(0.15))
                            .frame(width: 26, height: 26)
                        Text(d.day.formatted(.dateTime.weekday(.narrow)))
                            .font(ClayFont.footnote).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Dose logged on \(n) of the last 7 days")
        }
    }
}
