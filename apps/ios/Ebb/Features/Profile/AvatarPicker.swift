import SwiftUI

/// Sheet for choosing your animal. Tapping one picks it and closes the sheet.
struct AvatarPicker: View {
    @Binding var selection: AvatarAnimal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
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
        }
        .padding(24)
        .presentationDetents([.medium])
        .sensoryFeedback(.selection, trigger: selection)
    }
}
