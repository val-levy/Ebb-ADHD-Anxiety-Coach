import SwiftUI

/// A soft cloud gliding across the sky. Blur is rasterized once; only its position animates.
struct DriftingCloud: View {
    let width: CGFloat
    let duration: Double
    let start: Double
    let skyWidth: CGFloat

    var body: some View {
        Ellipse()
            .fill(.white.opacity(0.8))
            .frame(width: width, height: width * 0.32)
            .padding(24)   // room for the blur so drawingGroup doesn't clip it square
            .blur(radius: 10)
            .drawingGroup()
            .offset(x: -width)
            .drift(distance: skyWidth + width, duration: duration, start: start)
    }
}
