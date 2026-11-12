import SwiftUI

/// Reflect tab: this week's graphs, what helped, and patterns. Press and hold a block, then drag it onto another to reorder.
/// To add a block: add a ReflectModule case and its view below.
struct ReflectView: View {
    @AppStorage("reflectOrder") private var saved = ""
    @State private var targeted: ReflectModule?

    var body: some View {
        let order = ReflectModule.order(from: saved)
        SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
            ForEach(Array(order.enumerated()), id: \.element) { i, module in
                content(module)
                    .scaleEffect(targeted == module ? 0.97 : 1)
                    .opacity(targeted == module ? 0.7 : 1)
                    .draggable(module.rawValue)
                    .dropDestination(for: String.self) { items, _ in
                        guard let dragged = items.first.flatMap(ReflectModule.init(rawValue:)) else { return false }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            saved = ReflectModule.encode(ReflectModule.moving(order, dragged, onto: module))
                        }
                        return true
                    } isTargeted: { targeted = $0 ? module : (targeted == module ? nil : targeted) }
                    .accessibilityAction(named: "Move up") { move(module, by: -1, in: order) }
                    .accessibilityAction(named: "Move down") { move(module, by: 1, in: order) }
                    .popIn(i)
            }
            Text("Press and hold a block to move it.").font(ClayFont.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            if !saved.isEmpty {
                Button("Reset order") { withAnimation { saved = "" } }.font(ClayFont.footnote).frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder private func content(_ module: ReflectModule) -> some View {
        switch module {
        case .resetsPerDay: ResetsPerDayChart()
        case .calmDrop: CalmDropChart()
        case .timeOfDay: TimeOfDayChart()
        case .stressors: StressorsChart()
        case .medication: MedicationLogChart()
        case .medVsStressors: MedVsStressorsCard()
        case .helped:
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("What helped")
                HelpedCard()
            }.mascotTip(.helped)
        case .patterns:
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Patterns")
                PatternsSection()
            }
        }
    }

    private func move(_ module: ReflectModule, by step: Int, in order: [ReflectModule]) {
        guard let i = order.firstIndex(of: module), order.indices.contains(i + step) else { return }
        withAnimation { saved = ReflectModule.encode(ReflectModule.moving(order, module, onto: order[i + step])) }
    }
}
