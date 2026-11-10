import SwiftUI

/// A soft rolling hill: rises from `base` to a rounded crest near `peakAt` (all fractions of the rect).
struct HillShape: Shape {
    let base: Double
    let crest: Double
    let peakAt: Double

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: base * h))
        p.addCurve(to: CGPoint(x: w, y: base * h),
                   control1: CGPoint(x: (peakAt - 0.3) * w, y: (crest - 0.12) * h),
                   control2: CGPoint(x: (peakAt + 0.3) * w, y: (crest - 0.12) * h))
        p.addLine(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: 0, y: h)); p.closeSubpath()
        return p
    }
}
