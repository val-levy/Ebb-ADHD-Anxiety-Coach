import SwiftUI

/// Bottom bar for the sliding pager: tap a tab to slide to it.
struct ClayTabBar: View {
    @Binding var tab: AppPage.Tab

    private let items: [(AppPage.Tab, String, String)] = [
        (.calm, "Calm", "leaf"), (.reflect, "Reflect", "sparkles"), (.profile, "Profile", "person.crop.circle"),
    ]

    var body: some View {
        HStack {
            ForEach(items, id: \.0) { item, title, symbol in
                Button { tab = item } label: {
                    VStack(spacing: 3) {
                        Image(systemName: symbol).font(ClayFont.title3)
                        Text(title).font(ClayFont.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(tab == item ? Theme.accent : .secondary)
                }
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
        .padding(.top, 10)
        .background(.bar)
    }
}
