import SwiftUI

/// Film-grain speckle that makes flat color feel tactile, like a photo of real clay.
/// Deterministic (same pattern every frame), so it never shimmers.
struct GrainOverlay: View {
    var opacity: Double = 0.12

    var body: some View {
        Canvas { ctx, size in
            var seed: UInt64 = 42
            func next() -> Double {   // tiny LCG; fine for decoration
                seed = seed &* 6364136223846793005 &+ 1442695040888963407
                return Double(seed >> 33) / Double(1 << 31)
            }
            for _ in 0..<Int(size.width * size.height / 30) {
                let rect = CGRect(x: next() * size.width, y: next() * size.height, width: 1.2, height: 1.2)
                ctx.fill(Path(rect), with: .color(next() > 0.5 ? .white : .black))
            }
        }
        .drawingGroup()   // rasterize once; moving content underneath doesn't redraw it
        .opacity(opacity)
        .blendMode(.overlay)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
