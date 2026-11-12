import SwiftUI

/// Draws a `ClayIconKind` in a unit square, scaled to the rect. Strokes are meant to be drawn with round caps.
struct ClayIconShape: Shape {
    let kind: ClayIconKind

    func path(in r: CGRect) -> Path {
        func p(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: r.minX + r.width * x, y: r.minY + r.height * y) }
        var path = Path()
        switch kind {
        case .chevronRight: path.move(to: p(0.38, 0.2)); path.addLine(to: p(0.68, 0.5)); path.addLine(to: p(0.38, 0.8))
        case .chevronLeft: path.move(to: p(0.62, 0.2)); path.addLine(to: p(0.32, 0.5)); path.addLine(to: p(0.62, 0.8))
        case .close:
            path.move(to: p(0.25, 0.25)); path.addLine(to: p(0.75, 0.75))
            path.move(to: p(0.75, 0.25)); path.addLine(to: p(0.25, 0.75))
        case .plus:
            path.move(to: p(0.5, 0.2)); path.addLine(to: p(0.5, 0.8))
            path.move(to: p(0.2, 0.5)); path.addLine(to: p(0.8, 0.5))
        case .check: path.move(to: p(0.2, 0.52)); path.addLine(to: p(0.42, 0.74)); path.addLine(to: p(0.8, 0.28))
        case .play: path.move(to: p(0.3, 0.2)); path.addLine(to: p(0.8, 0.5)); path.addLine(to: p(0.3, 0.8)); path.closeSubpath()
        case .next:
            path.move(to: p(0.2, 0.22)); path.addLine(to: p(0.62, 0.5)); path.addLine(to: p(0.2, 0.78)); path.closeSubpath()
            path.addRoundedRect(in: CGRect(x: r.minX + r.width * 0.72, y: r.minY + r.height * 0.22, width: r.width * 0.1, height: r.height * 0.56), cornerSize: CGSize(width: 3, height: 3))
        case .speakerOn, .speakerOff:
            path.move(to: p(0.15, 0.4)); path.addLine(to: p(0.32, 0.4)); path.addLine(to: p(0.55, 0.2))
            path.addLine(to: p(0.55, 0.8)); path.addLine(to: p(0.32, 0.6)); path.addLine(to: p(0.15, 0.6)); path.closeSubpath()
        case .trash:
            path.move(to: p(0.2, 0.28)); path.addLine(to: p(0.8, 0.28))
            path.move(to: p(0.4, 0.28)); path.addLine(to: p(0.4, 0.18)); path.addLine(to: p(0.6, 0.18)); path.addLine(to: p(0.6, 0.28))
            path.move(to: p(0.28, 0.28)); path.addLine(to: p(0.33, 0.82)); path.addLine(to: p(0.67, 0.82)); path.addLine(to: p(0.72, 0.28))
        case .gear:
            path.addEllipse(in: CGRect(x: r.minX + r.width * 0.3, y: r.minY + r.height * 0.3, width: r.width * 0.4, height: r.height * 0.4))
            for i in 0..<8 {
                let a = Double(i) * .pi / 4
                path.move(to: p(0.5 + 0.32 * cos(a), 0.5 + 0.32 * sin(a))); path.addLine(to: p(0.5 + 0.42 * cos(a), 0.5 + 0.42 * sin(a)))
            }
        case .pencil:
            path.move(to: p(0.28, 0.72)); path.addLine(to: p(0.72, 0.28))
            path.move(to: p(0.2, 0.8)); path.addLine(to: p(0.28, 0.72))
        case .arrowUp:
            path.move(to: p(0.5, 0.8)); path.addLine(to: p(0.5, 0.22))
            path.move(to: p(0.26, 0.46)); path.addLine(to: p(0.5, 0.22)); path.addLine(to: p(0.74, 0.46))
        case .grip:
            for y in [0.32, 0.5, 0.68] { path.move(to: p(0.22, y)); path.addLine(to: p(0.78, y)) }
        case .heart:
            path.move(to: p(0.5, 0.82))
            path.addCurve(to: p(0.14, 0.38), control1: p(0.2, 0.62), control2: p(0.1, 0.5))
            path.addCurve(to: p(0.5, 0.3), control1: p(0.18, 0.12), control2: p(0.44, 0.14))
            path.addCurve(to: p(0.86, 0.38), control1: p(0.56, 0.14), control2: p(0.82, 0.12))
            path.addCurve(to: p(0.5, 0.82), control1: p(0.9, 0.5), control2: p(0.8, 0.62))
        case .star:
            for i in 0..<10 {
                let a = -Double.pi / 2 + Double(i) * .pi / 5, rad = i.isMultiple(of: 2) ? 0.4 : 0.18
                let pt = p(0.5 + rad * cos(a), 0.52 + rad * sin(a))
                i == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
        case .sparkle:
            for i in 0..<8 {
                let a = -Double.pi / 2 + Double(i) * .pi / 4, rad = i.isMultiple(of: 2) ? 0.4 : 0.12
                let pt = p(0.5 + rad * cos(a), 0.5 + rad * sin(a))
                i == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            path.closeSubpath()
        case .pill:
            path.addRoundedRect(in: CGRect(x: r.minX + r.width * 0.12, y: r.minY + r.height * 0.34, width: r.width * 0.76, height: r.height * 0.32), cornerSize: CGSize(width: r.width, height: r.width))
        case .chat:
            path.addRoundedRect(in: CGRect(x: r.minX + r.width * 0.12, y: r.minY + r.height * 0.18, width: r.width * 0.76, height: r.height * 0.5), cornerSize: CGSize(width: r.width * 0.2, height: r.width * 0.2))
            path.move(to: p(0.3, 0.66)); path.addLine(to: p(0.26, 0.84)); path.addLine(to: p(0.48, 0.68)); path.closeSubpath()
        case .swap:
            path.move(to: p(0.32, 0.8)); path.addLine(to: p(0.32, 0.2)); path.move(to: p(0.16, 0.36)); path.addLine(to: p(0.32, 0.2)); path.addLine(to: p(0.48, 0.36))
            path.move(to: p(0.68, 0.2)); path.addLine(to: p(0.68, 0.8)); path.move(to: p(0.52, 0.64)); path.addLine(to: p(0.68, 0.8)); path.addLine(to: p(0.84, 0.64))
        case .clock:
            path.addEllipse(in: CGRect(x: r.minX + r.width * 0.15, y: r.minY + r.height * 0.15, width: r.width * 0.7, height: r.height * 0.7))
            path.move(to: p(0.5, 0.3)); path.addLine(to: p(0.5, 0.5)); path.addLine(to: p(0.64, 0.58))
        case .wind:
            path.addEllipse(in: CGRect(x: r.minX + r.width * 0.15, y: r.minY + r.height * 0.15, width: r.width * 0.7, height: r.height * 0.7))
        }
        return path
    }
}
