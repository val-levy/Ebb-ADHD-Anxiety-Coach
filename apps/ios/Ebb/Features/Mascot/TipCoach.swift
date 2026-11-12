import SwiftUI

/// The tip overlay: dims the screen except a spotlight on the section, and the mascot (a full clay drawing,
/// not an avatar) stands by a speech bubble on whichever side of the spotlight has room. Tap anywhere to continue.
struct TipCoach: View {
    let tip: Tip
    let spot: CGRect
    /// Where the spot will rest once the page has scrolled to it. The bubble is placed against this, so it never hops mid-scroll.
    let anchor: CGRect
    let screen: CGSize
    @AppStorage("seenTips") private var seen: [String] = []
    @AppStorage("profileAnimal") private var animal = AvatarAnimal.panda
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var below: Bool { anchor.midY < screen.height / 2 }
    /// Alternate sides tip to tip so the mascot hops back and forth.
    private var mascotLeft: Bool { (Tip.allCases.firstIndex(of: tip) ?? 0).isMultiple(of: 2) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.5)
                .mask {
                    Rectangle().overlay {
                        RoundedRectangle(cornerRadius: Theme.cardRadius + 6, style: .continuous)
                            .frame(width: spot.width + 12, height: spot.height + 12)
                            .position(x: spot.midX, y: spot.midY)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                }
            HStack(alignment: .bottom, spacing: 4) {
                if mascotLeft { mascot }
                VStack(alignment: .leading, spacing: 6) {
                    Text(tip.text).font(ClayFont.headline)
                    Text("Tap to continue").font(ClayFont.caption).foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(14)
                .clay(radius: 20)
                if !mascotLeft { mascot }
            }
            .padding(.horizontal, 20)
            .frame(width: screen.width)
            .fixedSize(horizontal: false, vertical: true)
            .alignmentGuide(.top) { d in below ? -(anchor.maxY + 16) : -(anchor.minY - 16 - d.height) }
            // Each new tip blows in like a bubble: pops up from the mascot's side and wobbles to size.
            .id(tip)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.3, anchor: below ? (mascotLeft ? .topLeading : .topTrailing) : (mascotLeft ? .bottomLeading : .bottomTrailing)).combined(with: .opacity)
                    .animation(.spring(response: 0.45, dampingFraction: 0.55)),
                removal: .scale(scale: 1.15).combined(with: .opacity).animation(.easeOut(duration: 0.18))))
        }
        .frame(width: screen.width, height: screen.height, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { seen.append(tip.rawValue) } }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Dismiss tip")
        .transition(.opacity)
    }

    private var mascot: some View {
        AnimalFigure(animal: animal, size: 84)
            .mascotPose(.for(tip), reduceMotion: reduceMotion)
            .shadow(color: .black.opacity(0.35), radius: 6, y: 5)
    }
}
