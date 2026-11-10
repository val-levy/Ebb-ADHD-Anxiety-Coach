import Foundation

/// Turns a brain dump into one 5-minute starting step.
/// Demo: picks the first item. The real version will ask a language model.
enum NextStepSuggester {
    static func suggest(from dump: String) -> String {
        let first = dump
            .split(whereSeparator: { ".\n,".contains($0) })
            .first
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard let first, !first.isEmpty else { return "Write one thing that's on your mind first." }
        return "For 5 minutes, just start: \(first.lowercased())."
    }
}
