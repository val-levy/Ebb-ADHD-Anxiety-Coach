import SwiftUI

/// One reset or guided session as a chunky lump of colored clay: a little clay face, bold title, short line, length chip.
struct OptionTile: View {
    let mood: FaceMood
    let title: String
    let detail: String
    let length: String
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    ClayFace(mood: mood, ink: .black.opacity(0.5), size: 60)
                        .background(.white.opacity(0.3), in: .circle)
                    Spacer(minLength: 0)
                    Text(length).font(ClayFont.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(.white.opacity(0.28), in: .capsule)
                }
                Spacer(minLength: 0)
                Text(title).font(ClayFont.title3).lineLimit(2).multilineTextAlignment(.leading)
                Text(detail).font(ClayFont.footnote).opacity(0.92).lineLimit(2).multilineTextAlignment(.leading)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .padding(14)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.heroRadius, style: .continuous)) }
            .clay(color, radius: Theme.heroRadius)
        }
    }
}
