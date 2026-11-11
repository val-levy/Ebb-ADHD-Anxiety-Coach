import Foundation
import Security

/// An integer in the Keychain. Survives app deletion, so the panic ladder can't be reset by reinstalling.
struct KeychainCounter {
    private let query: [String: Any]

    init(key: String) {
        query = [kSecClass as String: kSecClassGenericPassword,
                 kSecAttrService as String: "app.ebb.counter",
                 kSecAttrAccount as String: key]
    }

    var value: Int {
        var q = query
        q[kSecReturnData as String] = true
        var out: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess,
              let data = out as? Data, let s = String(data: data, encoding: .utf8) else { return 0 }
        return Int(s) ?? 0
    }

    func increment() {
        let data = Data(String(value + 1).utf8)
        if SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary) == errSecItemNotFound {
            var add = query
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            SecItemAdd(add as CFDictionary, nil)
        }
    }
}
