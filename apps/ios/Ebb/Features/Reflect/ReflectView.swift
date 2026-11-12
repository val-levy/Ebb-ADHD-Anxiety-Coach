import SwiftUI

/// Reflect tab: this week's graphs, what helped, and patterns (see ReflectBlocks).
struct ReflectView: View {
    var body: some View {
        SceneScreen(title: "Reflect", tips: .reflect, mascotAt: 0.78) { ReflectBlocks() }
    }
}
