import SwiftUI

/// Where each Reflect block sits (in the "reflectStack" space), so a drag can find the gap it is over.
struct ModuleFramesKey: PreferenceKey {
    static let defaultValue: [ReflectModule: CGRect] = [:]
    static func reduce(value: inout [ReflectModule: CGRect], nextValue: () -> [ReflectModule: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
