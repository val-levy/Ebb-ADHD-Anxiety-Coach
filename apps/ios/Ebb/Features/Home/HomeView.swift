import SwiftUI

/// The one calm tab: a panic hero up top, then a Quick / Guided toggle over a grid of options, then proof it passes.
struct HomeView: View {
    @EnvironmentObject private var store: ResetStore
    @EnvironmentObject private var calm: CalmStore
    @EnvironmentObject private var session: SessionStore
    /// The requested mode (picker taps and app-wide swipes write it); `shown` follows it with the right slide direction.
    @Binding var mode: CalmMode
    @State private var shown: CalmMode = .quick
    @State private var slideFrom: Edge = .trailing
    @Environment(\.calmModeArea) private var modeArea

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            SceneScreen(title: "Ebb", tips: .calm, mascotAt: 0.62) {
                PanicHeroCard { session.panicTapped { calm.activeProgram = .panic } }.mascotTip(.panic).floating().popIn(0)

                ModePicker(mode: Binding(get: { shown }, set: { mode = $0 })).mascotTip(.modePicker).popIn(1)   // tap a side, or swipe anywhere
                Text(shown.caption).font(ClayFont.footnote).foregroundStyle(.secondary)

                LazyVGrid(columns: columns, spacing: 14) {
                    switch shown {
                    case .quick:
                        ForEach(Array(Reset.allCases.enumerated()), id: \.element) { i, reset in
                            OptionTile(symbol: reset.symbol, title: reset.title, detail: reset.blurb) {
                                if session.requireSignIn(reason: "Sign in to use quick resets") { store.activeReset = reset }
                            }.popIn(i + 2)
                        }
                    case .guided:
                        ForEach(Array(CalmProgram.allCases.filter { $0 != .panic }.enumerated()), id: \.element) { i, program in
                            OptionTile(symbol: program.techniques(favorite: nil).first!.symbol,
                                       title: program.title, detail: "\(program.minutes) min · \(program.subtitle)") {
                                if session.requireSignIn(reason: "Sign in to use guided sessions") { calm.activeProgram = program }
                            }.popIn(i + 2)
                        }
                    }
                }
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { modeArea.wrappedValue = $0 }
                .mascotTip(.swipe)   // spotlight the cards you swipe across
                .id(shown)   // fresh pop-in when switching modes
                .transition(.asymmetric(insertion: .move(edge: slideFrom),
                                        removal: .move(edge: slideFrom == .trailing ? .leading : .trailing)).combined(with: .opacity))

                if let drop = calm.averageDrop {
                    CalmProgressCard(before: drop.before, after: drop.after, sessions: calm.history.count)
                }

                // Demo: in the real app a stress detector (Watch/BT sensor, later) triggers this.
                Button("Demo: simulate a stress nudge") { store.isNudgeShowing = true }
                    .font(ClayFont.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
            .task { await calm.load() }
            .onChange(of: mode) { _, next in select(next) }
            .fullScreenCover(item: $calm.activeProgram, onDismiss: session.panicSessionEnded) { GuidedSessionFlow(program: $0) }
        }
    }

    /// Set the slide direction first, then switch on the next pass: a leaving view keeps the transition it had
    /// when last rendered, so the direction must already be correct before the mode changes.
    private func select(_ next: CalmMode) {
        guard next != shown else { return }
        slideFrom = next == .guided ? .trailing : .leading
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { shown = next }
        }
    }
}
