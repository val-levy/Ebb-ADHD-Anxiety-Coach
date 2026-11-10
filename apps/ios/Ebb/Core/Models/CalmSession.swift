import Foundation

/// A finished calm session. Mirrors a row in `calm_sessions`.
/// Intensity uses a 0–10 scale (like SUDS, the standard self-rated distress scale).
struct CalmSession: Codable {
    var program: CalmProgram
    var intensity_before: Int
    var intensity_after: Int?
    var helped_technique: CalmTechnique?   // what the user said helped most; drives personalization
    var created_at: Date?
}
