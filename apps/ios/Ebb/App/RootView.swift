import SwiftUI

/// Tab bar shell plus the app-wide overlays (nudge sheet, full-screen reset player).
struct RootView: View {
    @EnvironmentObject private var store: ResetStore
    @State private var tab: AppPage.Tab = .calm
    @State private var calmMode: CalmMode = .quick
    @State private var swipeLocks = 0
    /// Decided on a drag's first movement: sideways drags freeze vertical scrolling until the finger lifts.
    @State private var draggingSideways: Bool?
    @State private var calmModeArea = CGRect.zero

    var body: some View {
        TabView(selection: $tab) {
            HomeView(mode: $calmMode).tabItem { Label("Calm", systemImage: "leaf") }.tag(AppPage.Tab.calm)
            ReflectView().tabItem { Label("Reflect", systemImage: "bubble") }.tag(AppPage.Tab.reflect)
            ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(AppPage.Tab.profile)
        }
        // Swipe sideways anywhere to move along Quick ⇄ Guided ⇄ Reflect ⇄ Profile.
        // Only clearly horizontal swipes count, so vertical scrolling and taps are untouched.
        .simultaneousGesture(DragGesture(minimumDistance: 12, coordinateSpace: .global).onChanged { g in
            guard draggingSideways == nil, swipeLocks == 0 else { return }
            draggingSideways = abs(g.translation.width) > abs(g.translation.height)
        }.onEnded { g in
            defer { draggingSideways = nil }
            guard swipeLocks == 0, draggingSideways == true else { return }
            let dx = g.translation.width
            guard abs(dx) > 60, abs(dx) > abs(g.translation.height) * 1.5 else { return }
            let here = AppPage(tab: tab, calmMode: calmMode)
            let onGrid = tab == .calm && calmModeArea.contains(g.startLocation)
            let next = onGrid ? here.swiped(dx: dx) : here.swipedTab(dx: dx)
            if onGrid { calmMode = next == .calmQuick ? .quick : .guided }
            withAnimation(.snappy) { tab = next.tab }
        })
        .scrollDisabled(draggingSideways == true)
        .environment(\.tabSwipeLocks, $swipeLocks)
        .environment(\.calmModeArea, $calmModeArea)
        .sensoryFeedback(.selection, trigger: tab)
        .tint(Theme.accent)
        .buttonStyle(SquishyButtonStyle())
        .sheet(isPresented: $store.isNudgeShowing) {
            NudgeSheet().presentationDetents([.height(280)])
        }
        .fullScreenCover(item: $store.activeReset) { ResetView(reset: $0) }
        .onAppear { KeyboardDismisser.shared.install() }
    }
}
