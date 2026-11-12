import SwiftUI

/// Tab layout: landscape scene, a chunky clay title resting on the meadow, then a white rounded panel holding the content.
struct SceneScreen<Content: View>: View {
    let title: String
    /// Whose tips the ? replays.
    let tips: Tip.Screen
    /// Where along the panel's top edge the mascot hides (0 = left, 1 = right).
    var mascotAt: CGFloat = 0.7
    @ViewBuilder let content: Content
    @AppStorage("seenTips") private var seen: [String] = []
    /// When this screen was last left. Away longer than a quick mis-swipe → back to the top on return.
    @State private var leftAt: Date?
    @State private var control = ScrollControl()

    var body: some View {
        ScrollViewReader { reader in
        ScrollView {
            VStack(spacing: 0) {
                // Measure and counter-offset in the same layout pass (GeometryReader), so the scene stays perfectly
                // still while the panel slides. A @State round trip lags a frame and makes the scene shake.
                GeometryReader { geo in
                    let overscroll = max(0, geo.frame(in: .scrollView).minY)
                    LandscapeBackdrop()
                        .frame(height: 260)
                        .overlay(alignment: .top) {
                            // Pull down: the panel slides away and uncovers the hidden meadow under the scene.
                            if overscroll > 1 { SecretMeadow(pull: overscroll).offset(y: 220) }
                        }
                        .offset(y: -overscroll)
                }
                .frame(height: 260)
                .zIndex(-1)
                .id("top")
                VStack(alignment: .leading, spacing: 14) { content }
                    .padding(20)
                    // iOS's floating tab bar overlays scroll content; reserve a calm, tappable exit runway below cards.
                    .safeAreaPadding(.bottom, 92)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.canvas, in: UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
                    // The mascot hides behind the panel's top edge and peeks up over it.
                    .background(alignment: .topLeading) {
                        GeometryReader { geo in
                            MascotPeek().offset(x: geo.size.width * mascotAt - 27, y: -54 + 8)
                        }
                    }
                    // Title sits on the meadow just above the panel and rides with it when you pull down.
                    .overlay(alignment: .topLeading) {
                        ClayTitle(text: title)
                            .alignmentGuide(.top) { $0[.bottom] + 6 }
                            .padding(.leading, 20)
                    }
                    .overlay(alignment: .topTrailing) {
                        Button("Replay tips", systemImage: "questionmark.circle.fill") {
                            withAnimation { seen.removeAll { Tip(rawValue: $0)?.screen == tips } }
                        }
                        .labelStyle(.iconOnly).font(ClayFont.system(size: 28)).foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        .alignmentGuide(.top) { $0[.bottom] + 10 }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, -40)
            }
        }
        .scrollPosition(Bindable(control).position)
        .onScrollGeometryChange(for: CGPoint.self) { CGPoint(x: $0.containerSize.height, y: $0.contentOffset.y) } action: { _, new in
            control.viewport = new.x; control.offset = new.y
        }
        .environment(\.scrollControl, control)
        .onDisappear { leftAt = .now }
        .onAppear {
            if let leftAt, Date.now.timeIntervalSince(leftAt) > 0.8 { reader.scrollTo("top", anchor: .top) }
            leftAt = nil
        }
        }
        .scrollDismissesKeyboard(.interactively)   // dragging the page down also tucks the keyboard away
        .ignoresSafeArea(edges: .top)
        .background { VStack(spacing: 0) { Theme.skyTop; Theme.canvas } .ignoresSafeArea() }
        .overlayPreferenceValue(TipSpotKey.self) { spot in
            if let spot {
                GeometryReader { geo in
                    TipCoach(tip: spot.tip, spot: geo[spot.bounds], screen: geo.size)
                        .task(id: spot.tip) {   // bring an off-screen section into view first
                            try? await Task.sleep(for: .milliseconds(150))
                            control.reveal(geo[spot.bounds], screenHeight: geo.size.height)
                        }
                }
                .ignoresSafeArea()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
