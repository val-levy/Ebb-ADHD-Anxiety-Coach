import Foundation

/// Lets `@AppStorage` hold a Codable array as JSON.
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let value = try? JSONDecoder().decode([Element].self, from: Data(rawValue.utf8)) else { return nil }
        self = value
    }
    public var rawValue: String {
        (try? JSONEncoder().encode(self)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
