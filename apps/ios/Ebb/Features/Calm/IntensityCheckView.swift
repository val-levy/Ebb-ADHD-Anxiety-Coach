import SwiftUI

/// 0–10 intensity check with big tap targets (fine motor control is poor during panic).
struct IntensityCheckView: View {
    let title: String
    @Binding var value: Int
    let actionTitle: String
    let onContinue: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Text(title).font(ClayFont.title.bold()).multilineTextAlignment(.center)
            Text("0 is calm, 10 is the worst it gets.").opacity(0.8)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0...10, id: \.self) { n in
                    Button("\(n)") { value = n }
                        .font(ClayFont.title2.bold())
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .clay(n == value ? .white : .white.opacity(0.25), radius: 18)
                        .foregroundStyle(n == value ? Theme.accent : .white)
                        .accessibilityAddTraits(n == value ? .isSelected : [])
                }
            }
            Spacer()
            Button(actionTitle, action: onContinue)
                .font(ClayFont.title3.bold())
                .frame(maxWidth: .infinity, minHeight: 56)
                .clay(.white, radius: 28)
                .foregroundStyle(Theme.accent)
        }
        .foregroundStyle(.white)
        .padding(24)
    }
}
