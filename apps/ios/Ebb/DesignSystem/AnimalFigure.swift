import SwiftUI

/// One clay animal drawn at a target size. Tall and wide animals are zoomed so they read the same size.
struct AnimalFigure: View {
    let animal: AvatarAnimal
    var size: CGFloat = 72

    var body: some View {
        figure.scaleEffect(size / 72 * fit).frame(width: size, height: size)
    }

    private var fit: CGFloat {
        switch animal {
        case .panda, .penguin: 1.0
        case .lion, .elephant, .flamingo: 0.8
        case .giraffe: 0.55
        }
    }

    @ViewBuilder private var figure: some View {
        switch animal {
        case .panda: Panda()
        case .penguin: Penguin()
        case .lion: Lion()
        case .elephant: Elephant()
        case .giraffe: Giraffe()
        case .flamingo: Flamingo()
        }
    }
}
