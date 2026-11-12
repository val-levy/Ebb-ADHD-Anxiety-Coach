import SwiftUI

/// A tiny pressed-in clay face (two eyes, a mouth, rosy cheeks). Replaces icon glyphs so tiles feel like characters.
struct ClayFace: View {
    let mood: FaceMood
    var ink: Color = .black.opacity(0.55)
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            HStack(spacing: size * 0.24) { eye(mood.leftEye); eye(mood.rightEye) }.offset(y: -size * 0.08)
            HStack(spacing: size * 0.5) { cheek; cheek }.offset(y: size * 0.1)
            mouth.offset(y: size * 0.2)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var cheek: some View { Circle().fill(Theme.clayPink.opacity(0.55)).frame(width: size * 0.13) }

    @ViewBuilder private func eye(_ eye: FaceMood.Eye) -> some View {
        let d = size * 0.15
        switch eye {
        case .open: Ellipse().fill(ink).frame(width: size * 0.09, height: size * 0.13)
        case .happy: arc(0.5, 1.0, d).offset(y: d * 0.25)
        case .sleepy: arc(0, 0.5, d).offset(y: -d * 0.25)
        }
    }

    @ViewBuilder private var mouth: some View {
        let w = size * 0.3
        switch mood.mouth {
        case .smile: arc(0.12, 0.38, w).offset(y: -w * 0.3)
        case .o: Ellipse().fill(ink).frame(width: size * 0.11, height: size * 0.14)
        case .flat: Capsule().fill(ink).frame(width: size * 0.2, height: size * 0.05)
        case .grin: Circle().trim(from: 0, to: 0.5).fill(ink).frame(width: w, height: w).offset(y: -w * 0.25)
        case .wave: wave(w)
        }
    }

    private func arc(_ from: CGFloat, _ to: CGFloat, _ d: CGFloat) -> some View {
        Circle().trim(from: from, to: to)
            .stroke(ink, style: .init(lineWidth: size * 0.05, lineCap: .round))
            .frame(width: d, height: d)
    }

    private func wave(_ w: CGFloat) -> some View {
        Path { p in
            let step = w / 6, h = size * 0.04
            p.move(to: .zero)
            for i in 1...6 { p.addLine(to: CGPoint(x: step * CGFloat(i), y: i.isMultiple(of: 2) ? 0 : h)) }
        }
        .stroke(ink, style: .init(lineWidth: size * 0.045, lineCap: .round, lineJoin: .round))
        .frame(width: w, height: size * 0.04)
    }
}
