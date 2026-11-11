import Foundation

/// A short, factual reflection on the person's own recent reset and check-in history.
struct WeeklyInsight: Identifiable, Hashable {
    let id: String
    let symbol: String
    let text: String
}
