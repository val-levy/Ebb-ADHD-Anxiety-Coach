import SwiftUI

/// A clay animal sitting in a soft round tile.
struct AnimalAvatar: View {
    let animal: AvatarAnimal
    var size: CGFloat = 72

    var body: some View {
        Circle().fill(Theme.skyBottom)
            .overlay(alignment: .bottom) { Circle().fill(Theme.hillMeadow).frame(height: size * 0.5).offset(y: size * 0.32) }
            .overlay { AnimalFigure(animal: animal, size: size).offset(y: size * 0.04) }
            .clipShape(Circle())
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
            .accessibilityLabel(animal.name)
    }
}
