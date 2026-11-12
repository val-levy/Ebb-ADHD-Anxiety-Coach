import SwiftUI

/// Reflect tab: this week's graphs, what helped, and patterns. Press and hold a block, drag it, and let go:
/// it snaps into the gap marked by the line. To add a block: add a ReflectModule case and its view below.
struct ReflectView: View {
    @AppStorage("reflectOrder") private var saved = ""
    @State private var frames: [ReflectModule: CGRect] = [:]
    @State private var dragging: ReflectModule?
    @State private var startCenter: CGFloat = 0
    @State private var lift: CGFloat = 0
    @Environment(\.tabSwipeLocks) private var swipeLocks

    var body: some View {
        let order = ReflectModule.order(from: saved)
        SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(order.enumerated()), id: \.element) { i, module in
                    let isDragged = dragging == module
                    content(module)
                        .modifier(FirstBlockTip(isFirst: i == 0))
                        .background(GeometryReader { Color.clear.preference(key: ModuleFramesKey.self, value: [module: $0.frame(in: .named("reflectStack"))]) })
                        .scaleEffect(isDragged ? 1.03 : 1)
                        .shadow(color: .black.opacity(isDragged ? 0.28 : 0), radius: 18, y: 10)
                        .offset(y: isDragged ? lift : 0)
                        .zIndex(isDragged ? 1 : 0)
                        .onLongPressGesture(minimumDuration: 0.35) { begin(module) }
                        .simultaneousGesture(follow(module, in: order))
                        .accessibilityAction(named: "Move up") { move(module, to: i - 1, in: order) }
                        .accessibilityAction(named: "Move down") { move(module, to: i + 1, in: order) }
                        .popIn(i)
                }
            }
            .coordinateSpace(name: "reflectStack")
            .onPreferenceChange(ModuleFramesKey.self) { frames = $0 }
            .overlay(alignment: .topLeading) { insertionLine(order) }
            .sensoryFeedback(.impact, trigger: dragging)
            Text("Press and hold a block to move it.").font(ClayFont.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            if !saved.isEmpty {
                Button("Reset order") { withAnimation { saved = "" } }.font(ClayFont.footnote).frame(maxWidth: .infinity)
            }
        }
        .scrollDisabled(dragging != nil)   // only while a block is held; the press-and-hold itself never blocks scrolling
    }

    /// Where the dragged block would land.
    private func gap(_ module: ReflectModule, in order: [ReflectModule]) -> Int {
        let mids = order.filter { $0 != module }.compactMap { frames[$0]?.midY }
        return ReflectModule.gap(midYs: mids, centerY: startCenter + lift)
    }

    @ViewBuilder private func insertionLine(_ order: [ReflectModule]) -> some View {
        if let module = dragging {
            let others = order.filter { $0 != module }.compactMap { frames[$0] }
            let g = gap(module, in: order)
            if !others.isEmpty {
                let y = g == 0 ? others[0].minY - 7 : others[min(g, others.count) - 1].maxY + 7
                Capsule().fill(Theme.accent).frame(height: 5).frame(maxWidth: .infinity)
                    .offset(y: y - 2.5)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: g)
                    .allowsHitTesting(false)
            }
        }
    }

    /// Armed by the press-and-hold (which fails as soon as the finger moves, so scrolling stays normal).
    private func begin(_ module: ReflectModule) {
        guard dragging == nil else { return }
        dragging = module
        startCenter = frames[module]?.midY ?? 0
        lift = 0
        swipeLocks.wrappedValue += 1
    }

    /// Only moves a block that is armed; scrolling is switched off while one is held.
    private func follow(_ module: ReflectModule, in order: [ReflectModule]) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named("reflectStack"))
            .onChanged { if dragging == module { lift = $0.translation.height } }
            .onEnded { _ in finish(module, in: order) }
    }

    private func finish(_ module: ReflectModule, in order: [ReflectModule]) {
        guard dragging == module else { return }
        let target = gap(module, in: order)
        swipeLocks.wrappedValue -= 1
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            saved = ReflectModule.encode(ReflectModule.moving(order, module, toGap: target))
            dragging = nil
            lift = 0
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
            }
        case .patterns:
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Patterns")
                PatternsSection()
            }
        }
    }

    private func move(_ module: ReflectModule, to index: Int, in order: [ReflectModule]) {
        guard order.indices.contains(index) else { return }
        withAnimation { saved = ReflectModule.encode(ReflectModule.moving(order, module, toGap: index)) }
    }
}

/// The Reflect tip points at whichever block is on top, so it is always on screen (the ? replays it).
private struct FirstBlockTip: ViewModifier {
    let isFirst: Bool
    func body(content: Content) -> some View {
        if isFirst { content.mascotTip(.helped) } else { content }
    }
}
