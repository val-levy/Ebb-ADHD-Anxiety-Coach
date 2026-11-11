import SwiftUI

/// Sheet for choosing your animal. Tapping one picks it and closes the sheet.
struct AvatarPicker: View {
    @Binding var selection: AvatarAnimal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 12)
            Text("Pick your animal").font(ClayFont.title2.bold())
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 18) {
                ForEach(AvatarAnimal.allCases) { a in
                    Button { selection = a; dismiss() } label: {
                        VStack(spacing: 6) {
                            AnimalAvatar(animal: a, size: 88)
                                .overlay(Circle().stroke(Theme.accent, lineWidth: a == selection ? 4 : 0))
                            Text(a.name).font(ClayFont.subheadline).foregroundStyle(.primary)
                        }
                    }
                }
            }
            Spacer(minLength: 12)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clayCanvas()
        .presentationDetents([.fraction(0.72)])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.selection, trigger: selection)
    }
}
