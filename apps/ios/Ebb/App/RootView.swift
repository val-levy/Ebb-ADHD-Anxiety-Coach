import SwiftUI

/// Tab bar shell plus the app-wide overlays (nudge sheet, full-screen reset player).
struct RootView: View {
    @EnvironmentObject private var store: ResetStore
    @EnvironmentObject private var nudges: NudgeStore
    @EnvironmentObject private var session: SessionStore
    @AppStorage("nudgePlan") private var nudgePlan = ScheduleItem.defaultNudges
    @AppStorage("profileAnimal") private var profileAnimal = AvatarAnimal.panda
    @State private var tab: AppPage.Tab = .calm
    @State private var calmMode: CalmMode = .quick
    @State private var swipeLocks = 0
    /// Decided on a drag's first movement: sideways drags freeze vertical scrolling until the finger lifts.
    @State private var draggingSideways: Bool?
    @State private var calmModeArea = CGRect.zero

    var body: some View {
        TabView(selection: $tab) {
            HomeView(mode: $calmMode).tabItem { Label { Text("Calm") } icon: { AnimalTabIcon.image(.panda, selected: tab == .calm) } }.tag(AppPage.Tab.calm)
            ReflectView().tabItem { Label { Text("Reflect") } icon: { AnimalTabIcon.image(.penguin, selected: tab == .reflect) } }.tag(AppPage.Tab.reflect)
            ProfileView().tabItem { Label { Text("Profile") } icon: { AnimalTabIcon.image(profileAnimal, selected: tab == .profile) } }.tag(AppPage.Tab.profile)
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
        .sheet(isPresented: $nudges.isShowing) {
            NudgeSheet()
                .presentationDetents([.fraction(0.72)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $session.sheet) { sheet in
            switch sheet {
            case .signIn(let reason): SignInSheet(reason: reason, onSkip: session.skipAction).environmentObject(session)
            case .setup: ProfileSetupSheet(model: ProfileSetupModel(session: session, appleName: session.appleName))
            case .newPassword: NewPasswordSheet().environmentObject(session)
            }
        }
        .fullScreenCover(isPresented: $session.panicBlocked, onDismiss: session.showQueuedSheet) { PanicBlockedView().environmentObject(session) }
        .fullScreenCover(item: $store.activeReset) { ResetView(reset: $0) }
        .onAppear { KeyboardDismisser.shared.install() }
        .onOpenURL { url in Task { await session.handleURL(url) } }
        .task { await nudges.start(plan: nudgePlan) }
    }
}
