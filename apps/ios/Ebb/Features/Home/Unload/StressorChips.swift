import SwiftUI

/// The stressor chips, wrapping onto a second line when the screen is narrow.
struct StressorChips: View {
    @EnvironmentObject private var logs: LogStore

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(Stressor.allCases)
            VStack(alignment: .leading, spacing: 8) {
                row(Array(Stressor.allCases.prefix(3)))
                row(Array(Stressor.allCases.dropFirst(3)))
            }
        }
    }

    private func row(_ items: [Stressor]) -> some View {
        HStack(spacing: 8) {
            ForEach(items) { s in
                Button { Task { await logs.logStressor(s) } } label: {
                    Label { Text(s.title) } icon: { ClayIcon(kind: .forSymbol(s.symbol), size: 18).foregroundStyle(.white).frame(width: 30, height: 30).background(Theme.iconColors(for: s.symbol).0, in: .circle) }.font(ClayFont.footnote)
                        .padding(.horizontal, 10).padding(.vertical, 8).clay()
                }
            }
        }
    }
}
