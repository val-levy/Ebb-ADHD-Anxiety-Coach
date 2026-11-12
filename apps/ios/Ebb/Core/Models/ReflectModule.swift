import Foundation

/// The movable blocks on the Reflect page. The user's order is saved as a comma-separated string of raw values.
enum ReflectModule: String, CaseIterable, Hashable {
    case resetsPerDay, calmDrop, timeOfDay, stressors, medication, medVsStressors, helped, patterns

    /// Saved order, repaired: unknown names dropped, duplicates ignored, new modules appended in default order.
    static func order(from raw: String) -> [ReflectModule] {
        var saved: [ReflectModule] = []
        for m in raw.split(separator: ",").compactMap({ ReflectModule(rawValue: String($0)) }) where !saved.contains(m) { saved.append(m) }
        return saved + allCases.filter { !saved.contains($0) }
    }

    static func encode(_ order: [ReflectModule]) -> String { order.map(\.rawValue).joined(separator: ",") }

    /// `dragged` takes the place of `target`; everything between shifts over by one.
    static func moving(_ order: [ReflectModule], _ dragged: ReflectModule, onto target: ReflectModule) -> [ReflectModule] {
        guard dragged != target, let from = order.firstIndex(of: dragged), let to = order.firstIndex(of: target) else { return order }
        var next = order
        next.remove(at: from)
        next.insert(dragged, at: to)
        return next
    }

    static func selfCheck() {
        assert(order(from: "") == allCases)
        assert(order(from: "patterns,bogus,patterns,helped") == [.patterns, .helped, .resetsPerDay, .calmDrop, .timeOfDay, .stressors, .medication, .medVsStressors])
        assert(moving([.resetsPerDay, .calmDrop, .timeOfDay], .timeOfDay, onto: .resetsPerDay) == [.timeOfDay, .resetsPerDay, .calmDrop])
        assert(moving([.resetsPerDay, .calmDrop, .timeOfDay], .resetsPerDay, onto: .timeOfDay) == [.calmDrop, .timeOfDay, .resetsPerDay])
    }
}
