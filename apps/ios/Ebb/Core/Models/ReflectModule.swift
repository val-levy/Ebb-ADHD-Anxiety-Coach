import CoreGraphics
import Foundation

/// The movable blocks on the Reflect page. The user's order is saved as a comma-separated string of raw values.
enum ReflectModule: String, CaseIterable, Hashable {
    case resetsPerDay, calmDrop, timeOfDay, stressors, medication, medVsStressors, helped, patterns

    /// These blocks have a label above their card, so their handle sits on the card, not the block.
    var hasLabel: Bool { self == .helped || self == .patterns }

    /// Saved order, repaired: unknown names dropped, duplicates ignored, new modules appended in default order.
    static func order(from raw: String) -> [ReflectModule] {
        var saved: [ReflectModule] = []
        for m in raw.split(separator: ",").compactMap({ ReflectModule(rawValue: String($0)) }) where !saved.contains(m) { saved.append(m) }
        return saved + allCases.filter { !saved.contains($0) }
    }

    static func encode(_ order: [ReflectModule]) -> String { order.map(\.rawValue).joined(separator: ",") }

    /// Moves `dragged` into gap `gap` (0 = top) counted among the *other* modules.
    static func moving(_ order: [ReflectModule], _ dragged: ReflectModule, toGap gap: Int) -> [ReflectModule] {
        var next = order.filter { $0 != dragged }
        next.insert(dragged, at: min(max(gap, 0), next.count))
        return next
    }

    /// Which gap a dragged block's center is over, given the other blocks' center heights (top to bottom).
    static func gap(midYs: [CGFloat], centerY: CGFloat) -> Int { midYs.filter { $0 < centerY }.count }

    static func selfCheck() {
        assert(order(from: "") == allCases)
        assert(order(from: "patterns,bogus,patterns,helped") == [.patterns, .helped, .resetsPerDay, .calmDrop, .timeOfDay, .stressors, .medication, .medVsStressors])
        let o: [ReflectModule] = [.resetsPerDay, .calmDrop, .timeOfDay]
        assert(moving(o, .timeOfDay, toGap: 0) == [.timeOfDay, .resetsPerDay, .calmDrop])
        assert(moving(o, .resetsPerDay, toGap: 2) == [.calmDrop, .timeOfDay, .resetsPerDay])
        assert(moving(o, .resetsPerDay, toGap: 1) == [.calmDrop, .resetsPerDay, .timeOfDay])
        assert(gap(midYs: [10, 30], centerY: 20) == 1 && gap(midYs: [10, 30], centerY: 50) == 2)
    }
}
