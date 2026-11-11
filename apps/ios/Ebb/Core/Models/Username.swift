import Foundation

/// Username rules, matching the `profiles.username` check in Postgres.
enum Username {
    static func normalize(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValid(_ name: String) -> Bool {
        name.wholeMatch(of: /[a-z0-9_]{3,20}/) != nil
    }

    static func selfCheck() {
        assert(normalize("  Val_01 ") == "val_01")
        assert(!isValid("ab"))
        assert(!isValid("a b"))
        assert(!isValid(String(repeating: "a", count: 21)))
        assert(isValid("ebb_fan"))
    }
}
