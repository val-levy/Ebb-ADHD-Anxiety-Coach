import SwiftUI

/// Sliding pager shell plus the app-wide overlays (nudge sheet, full-screen reset player).
struct RootView: View {
    @EnvironmentObject private var store: ResetStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tab: AppPage.Tab = .calm
    @State private var calmMode: CalmMode = .quick
    @State private var swipeLocks = 0
    /// Decided on a drag's first movement: sideways drags freeze vertical scrolling until the finger lifts.
    @State private var draggingSideways: Bool?
    /// How far the finger has pulled the pager while a drag is crossing between tabs.
    @State private var pull: CGFloat = 0

    private let tabs: [AppPage.Tab] = [.calm, .reflect, .profile]

    var body: some View {
        GeometryReader { geo in
            let index = CGFloat(tabs.firstIndex(of: tab)!)
            HStack(spacing: 0) {
                page(.calm) { HomeView(mode: $calmMode) }.frame(width: geo.size.width)
                page(.reflect) { ReflectView() }.frame(width: geo.size.width)
                page(.profile) { ProfileView() }.frame(width: geo.size.width)
            }
            .offset(x: -index * geo.size.width + pull)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ClayTabBar(tab: Binding(get: { tab }, set: { next in slide { tab = next } }))
        }
        // Swipe sideways anywhere to move along Quick ⇄ Guided ⇄ Reflect ⇄ Profile.
        // Crossing tabs, the pages follow the finger; Quick ⇄ Guided slides its own grid.
        .simultaneousGesture(DragGesture(minimumDistance: 12).onChanged { g in
            if draggingSideways == nil, swipeLocks == 0 {
                draggingSideways = abs(g.translation.width) > abs(g.translation.height)
            }
            guard draggingSideways == true, swipeLocks == 0 else { return }
            let dx = g.translation.width
            let here = AppPage(tab: tab, calmMode: calmMode)
            let next = here.swiped(dx: dx)
            if next == here { pull = dx * 0.25 }            // rubber band at either end
            else { pull = next.tab != tab ? dx : 0 }
        }.onEnded { g in
            defer { draggingSideways = nil }
            guard swipeLocks == 0, draggingSideways == true else { return slide { pull = 0 } }
            let dx = g.translation.width
            guard abs(dx) > 60, abs(dx) > abs(g.translation.height) * 1.5 else { return slide { pull = 0 } }
            let next = AppPage(tab: tab, calmMode: calmMode).swiped(dx: dx)
            if next.tab == .calm { calmMode = next == .calmQuick ? .quick : .guided }
            slide { tab = next.tab; pull = 0 }
        })
        .scrollDisabled(draggingSideways == true)
        .environment(\.tabSwipeLocks, $swipeLocks)
        .sensoryFeedback(.selection, trigger: tab)
        .tint(Theme.accent)
        .buttonStyle(SquishyButtonStyle())
        .sheet(isPresented: $store.isNudgeShowing) {
            NudgeSheet().presentationDetents([.height(280)])
        }
        .fullScreenCover(item: $store.activeReset) { ResetView(reset: $0) }
        .onAppear { KeyboardDismisser.shared.install() }
    }

    private func page<V: View>(_ t: AppPage.Tab, @ViewBuilder _ content: () -> V) -> some View {
        content().environment(\.isActivePage, t == tab)
    }

    /// Transform-only slide; Reduce Motion snaps instead.
    private func slide(_ change: () -> Void) {
        if reduceMotion { change() } else { withAnimation(.spring(response: 0.38, dampingFraction: 0.86), change) }
    }
}
