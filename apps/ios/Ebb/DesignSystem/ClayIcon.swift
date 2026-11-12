import SwiftUI

/// A hand-drawn clay icon: thick round-ended strokes (or a soft solid) in the current foreground color, pressed into
/// the surface with a highlight and a little shadow. Use instead of SF Symbols for buttons and controls.
struct ClayIcon: View {
    let kind: ClayIconKind
    var size: CGFloat = 24
    @ScaledMetric private var scale = 1

    var body: some View {
        let s = size * scale, line = s * 0.16
        let shape = ClayIconShape(kind: kind)
        ZStack {
            if kind.filled {
                shape.fill().overlay { shape.stroke(style: StrokeStyle(lineWidth: line * 0.7, lineCap: .round, lineJoin: .round)) }
            } else {
                shape.stroke(style: StrokeStyle(lineWidth: line, lineCap: .round, lineJoin: .round))
            }
            if kind == .speakerOff { ClayIconShape(kind: .close).stroke(style: StrokeStyle(lineWidth: line * 0.8, lineCap: .round)).scaleEffect(0.5).offset(x: s * 0.24) }
            if kind == .speakerOn { Arc().stroke(style: StrokeStyle(lineWidth: line * 0.8, lineCap: .round)).frame(width: s * 0.22, height: s * 0.4).offset(x: s * 0.3) }
        }
        .frame(width: s, height: s)
        .rotationEffect(kind == .pill ? .degrees(-35) : .zero)
        .shadow(color: .white.opacity(0.4), radius: 0, x: -0.5, y: -0.5)
        .shadow(color: .black.opacity(0.22), radius: 1, y: 1.5)
        .accessibilityHidden(kind.label.isEmpty)
        .accessibilityLabel(kind.label)
    }

    private struct Arc: Shape {
        func path(in r: CGRect) -> Path {
            var p = Path(); p.addArc(center: CGPoint(x: r.minX, y: r.midY), radius: r.height / 2, startAngle: .degrees(-50), endAngle: .degrees(50), clockwise: false); return p
        }
    }
}
