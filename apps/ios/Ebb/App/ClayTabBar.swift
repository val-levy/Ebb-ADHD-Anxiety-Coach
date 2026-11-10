import SwiftUI

/// Bottom bar for the sliding pager, drawn to match the system tab bar (system font, sizes, material, hairline).
struct ClayTabBar: View {
    @Binding var tab: AppPage.Tab

    private let items: [(AppPage.Tab, String, String)] = [
        (.calm, "Calm", "leaf"), (.reflect, "Reflect", "sparkles"), (.profile, "Profile", "person.crop.circle"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.0) { item, title, symbol in
                VStack(spacing: 2) {
                    Image(systemName: tab == item ? symbol + ".fill" : symbol)
                        .font(.system(size: 22))
                        .frame(height: 28)
                    Text(title).font(.system(size: 10, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(tab == item ? Theme.accent : Color(.systemGray))
                .contentShape(Rectangle())
                .onTapGesture { tab = item }   // native tab items don't squish
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(tab == item ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.top, 7)
        .padding(.bottom, 2)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}
