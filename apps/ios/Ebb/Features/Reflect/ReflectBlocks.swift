import SwiftUI

/// The Reflect blocks. In Edit layout, drag a block's handle and let go: it snaps into the gap marked by the line,
/// and the page scrolls when the finger nears the top or bottom edge. To add a block: add a ReflectModule case and its view below.
struct ReflectBlocks: View {
    @AppStorage("reflectOrder") private var saved = ""
    @State private var frames: [ReflectModule: CGRect] = [:]
    @State private var editing = false
    @State private var drag: ReflectDrag?
    @State private var lift: CGFloat = 0
    @Environment(\.tabSwipeLocks) private var swipeLocks
    @Environment(\.scrollControl) private var scroll
    private var dragging: ReflectModule? { drag?.module }

    var body: some View {
        let order = ReflectModule.order(from: saved)
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                if editing && !saved.isEmpty {
                    Button("Reset order") { withAnimation { saved = "" } }.font(ClayFont.footnote)
                }
                Spacer()
                Button(editing ? "Done" : "Edit layout", systemImage: editing ? "checkmark" : "arrow.up.arrow.down") {
                    withAnimation { editing.toggle() }
                }
                .font(ClayFont.subheadline).foregroundStyle(Theme.accent)
            }
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(order.enumerated()), id: \.element) { i, module in
                    let isDragged = dragging == module
                    content(module, in: order)
                        .modifier(FirstBlockTip(isFirst: i == 0))
                        .background(GeometryReader { Color.clear.preference(key: ModuleFramesKey.self, value: [module: $0.frame(in: .named("reflectStack"))]) })
                        .scaleEffect(isDragged ? 1.03 : 1)
                        .shadow(color: .black.opacity(isDragged ? 0.28 : 0), radius: 18, y: 10)
                        .offset(y: isDragged ? lift : 0)
                        .zIndex(isDragged ? 1 : 0)
                        .overlay(alignment: .topTrailing) { if editing && !module.hasLabel { grip(module, in: order) } }
                        .accessibilityAction(named: "Move up") { move(module, to: i - 1, in: order) }
                        .accessibilityAction(named: "Move down") { move(module, to: i + 1, in: order) }
                        .popIn(i)
                }
            }
            .coordinateSpace(name: "reflectStack")
            .onPreferenceChange(ModuleFramesKey.self) { frames = $0 }
            .overlay(alignment: .topLeading) { insertionLine(order) }
            .sensoryFeedback(.impact, trigger: dragging)
            if editing {
                Text("Drag a handle to move a block, then tap Done.").font(ClayFont.footnote).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .task(id: drag?.module) { await autoScroll() }
    }

    /// Where the dragged block would land.
    private func gap(_ module: ReflectModule, in order: [ReflectModule]) -> Int {
        let mids = order.filter { $0 != module }.compactMap { frames[$0]?.midY }
        return ReflectModule.gap(midYs: mids, centerY: (drag?.startCenter ?? 0) + lift)
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

    /// The only draggable spot, so the rest of the page scrolls like normal. Drag it; the block follows.
    private func grip(_ module: ReflectModule, in order: [ReflectModule]) -> some View {
        Image(systemName: "line.3.horizontal")
            .font(ClayFont.system(size: 18)).foregroundStyle(.secondary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged {
                    if drag == nil {
                        drag = ReflectDrag(module: module, startCenter: frames[module]?.midY ?? 0, startFinger: $0.location.y,
                                           startOffset: scroll.offset, finger: $0.location.y)
                        swipeLocks.wrappedValue += 1
                    }
                    if drag?.module == module { drag?.finger = $0.location.y; follow() }
                }
                .onEnded { _ in finish(module, in: order) })
    }

    private func follow() { if let drag { lift = drag.lift(offset: scroll.offset) } }

    /// While a block is held near the top or bottom edge, keep scrolling the page under the finger.
    private func autoScroll() async {
        while drag != nil, !Task.isCancelled {
            if let drag {
                let dy = ReflectDrag.autoScroll(finger: drag.finger, viewport: scroll.viewport)
                if dy != 0 { scroll.scroll(by: dy) }
                follow()
            }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func finish(_ module: ReflectModule, in order: [ReflectModule]) {
        guard drag?.module == module else { return }
        let target = gap(module, in: order)
        swipeLocks.wrappedValue -= 1
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            saved = ReflectModule.encode(ReflectModule.moving(order, module, toGap: target))
            drag = nil
            lift = 0
        }
    }

    @ViewBuilder private func content(_ module: ReflectModule, in order: [ReflectModule]) -> some View {
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
                HelpedCard().overlay(alignment: .topTrailing) { if editing { grip(module, in: order) } }
            }
        case .patterns:
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Patterns")
                PatternsSection().overlay(alignment: .topTrailing) { if editing { grip(module, in: order) } }
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
