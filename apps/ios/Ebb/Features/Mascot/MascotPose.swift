import SwiftUI

/// Little playful moves the mascot does while giving a tip. Transform-only (rotation, offset, scale) so they stay smooth;
/// still under Reduce Motion.
enum MascotPose: CaseIterable {
    case hop, lean, wiggle, squish, spin

    static func `for`(_ tip: Tip) -> MascotPose {
        allCases[(Tip.allCases.firstIndex(of: tip) ?? 0) % allCases.count]
    }

    /// The keyframes the pose loops through: (rotation degrees, y offset, horizontal scale, vertical scale).
    var phases: [Phase] {
        switch self {
        case .hop: [.rest, .init(y: -16), .rest, .init(sx: 1.1, sy: 0.9)]
        case .lean: [.rest, .init(angle: -14), .init(angle: -14), .rest]
        case .wiggle: [.rest, .init(angle: 10), .init(angle: -10), .init(angle: 8), .rest]
        case .squish: [.rest, .init(sx: 1.18, sy: 0.82), .init(y: -10, sx: 0.9, sy: 1.12), .rest]
        case .spin: [.rest, .init(y: -12, sx: -1), .rest, .init(y: -12, sx: 1)]
        }
    }

    struct Phase: Equatable {
        var angle: Double = 0, y: CGFloat = 0, sx: CGFloat = 1, sy: CGFloat = 1
        static let rest = Phase()
    }
}

extension View {
    /// Loops the mascot through `pose`, pausing on rest between moves.
    func mascotPose(_ pose: MascotPose, reduceMotion: Bool) -> some View {
        phaseAnimator(reduceMotion ? [.rest] : pose.phases) { view, p in
            view.rotationEffect(.degrees(p.angle), anchor: .bottom)
                .scaleEffect(x: p.sx, y: p.sy, anchor: .bottom)
                .offset(y: p.y)
        } animation: { p in
            p == .rest ? .spring(response: 0.35, dampingFraction: 0.5).delay(0.6) : .spring(response: 0.3, dampingFraction: 0.55)
        }
    }
}
