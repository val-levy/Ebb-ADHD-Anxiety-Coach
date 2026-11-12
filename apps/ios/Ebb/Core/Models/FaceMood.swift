import Foundation

/// The little clay face each tile wears: what the eyes and mouth do. Data only; `ClayFace` draws it.
enum FaceMood {
    case calm, puff, sigh, alert, cheer, steady, wink, brr

    enum Eye { case open, happy, sleepy }
    enum Mouth { case smile, o, flat, grin, wave }

    var leftEye: Eye {
        switch self {
        case .calm, .puff: .sleepy
        case .sigh, .cheer: .happy
        case .alert, .steady, .wink, .brr: .open
        }
    }

    var rightEye: Eye { self == .wink ? .happy : leftEye }

    var mouth: Mouth {
        switch self {
        case .calm, .alert: .smile
        case .puff, .sigh: .o
        case .steady: .flat
        case .cheer, .wink: .grin
        case .brr: .wave
        }
    }
}
