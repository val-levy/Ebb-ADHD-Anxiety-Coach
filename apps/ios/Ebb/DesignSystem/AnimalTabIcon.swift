import SwiftUI

/// A clay animal as a tab-bar icon. The tab bar can't host live views, so the avatar is rendered to a bitmap;
/// the selected tab gets a ring instead of the system tint.
@MainActor enum AnimalTabIcon {
    static func image(_ animal: AvatarAnimal, selected: Bool) -> Image {
        let view = AnimalAvatar(animal: animal, size: 30)
            .padding(2)
            .overlay { Circle().strokeBorder(Theme.claySea, lineWidth: selected ? 2.5 : 0) }
            .opacity(selected ? 1 : 0.7)
            .frame(width: 34, height: 34)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        guard let ui = renderer.uiImage else { return Image(systemName: "circle") }
        return Image(uiImage: ui.withRenderingMode(.alwaysOriginal))
    }
}
