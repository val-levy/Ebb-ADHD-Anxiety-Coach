import SwiftUI

/// One reset or guided session as a chunky lump of colored clay: a soft round icon bubble, bold white title, short detail.
struct OptionTile: View {
    let symbol: String
    let title: String
    let detail: String
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(ClayFont.system(size: 22, weight: .bold))
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.28), in: .circle)
                Spacer(minLength: 0)
                Text(title).font(ClayFont.headline).lineLimit(2).multilineTextAlignment(.leading)
                Text(detail).font(ClayFont.caption).opacity(0.9).lineLimit(2).multilineTextAlignment(.leading)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .padding(16)
            .overlay { GrainOverlay().clipShape(.rect(cornerRadius: Theme.heroRadius, style: .continuous)) }
            .clay(color, radius: Theme.heroRadius)
        }
    }
}
