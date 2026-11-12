import CoreGraphics

/// One drag of a Reflect block. Finger positions are screen (global) heights; `offset` is the page's scroll offset,
/// so the block keeps following the finger while the page auto-scrolls under it.
struct ReflectDrag {
    let module: ReflectModule
    let startCenter: CGFloat
    let startFinger: CGFloat
    let startOffset: CGFloat
    var finger: CGFloat

    /// How far the block has moved from where it started, in page coordinates.
    func lift(offset: CGFloat) -> CGFloat { (finger - startFinger) + (offset - startOffset) }

    /// Points to scroll per tick: 0 mid-screen, faster the nearer the finger is to the top or bottom edge.
    static func autoScroll(finger: CGFloat, viewport: CGFloat) -> CGFloat {
        let top: CGFloat = 130, bottom: CGFloat = 170, maxSpeed: CGFloat = 14
        if finger < top { return -maxSpeed * min(1, (top - finger) / top) }
        if finger > viewport - bottom { return maxSpeed * min(1, (finger - (viewport - bottom)) / bottom) }
        return 0
    }

    static func selfCheck() {
        assert(autoScroll(finger: 400, viewport: 800) == 0)
        assert(autoScroll(finger: 0, viewport: 800) == -14 && autoScroll(finger: 800, viewport: 800) == 14)
        assert(autoScroll(finger: 100, viewport: 800) < 0)
        let d = ReflectDrag(module: .calmDrop, startCenter: 0, startFinger: 300, startOffset: 50, finger: 340)
        assert(d.lift(offset: 80) == 70)
    }
}
