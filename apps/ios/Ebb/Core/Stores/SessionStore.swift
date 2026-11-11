import Foundation

enum AuthSheet: Identifiable {
    case signIn(reason: String), setup
    var id: String { if case .signIn(let r) = self { return "signIn:\(r)" }; return "setup" }
}

/// Who is signed in, which auth sheet is up, and the panic-ladder decision.
@MainActor
final class SessionStore: ObservableObject {
    @Published var profile: Profile?
    @Published var sheet: AuthSheet?
    var isSignedIn: Bool { profile != nil }

    let auth: AuthService
    private let panicUses = KeychainCounter(key: "panicUses")

    init(auth: AuthService = .shared) { self.auth = auth }

    /// Never blocks: offline launch leaves profile nil and the panic ladder runs from the Keychain.
    func start() async {
        do {
            try await auth.ensureSignedIn()
            profile = try await auth.fetchProfile()
        } catch {
            profile = nil
        }
    }

    func panicGate() -> PanicGate { .decide(usesSoFar: panicUses.value, signedIn: isSignedIn) }

    func recordPanicStart() { if !isSignedIn { panicUses.increment() } }

    /// True when signed in; otherwise opens sign-in (or setup if Apple is linked but no profile yet).
    func requireSignIn(reason: String) -> Bool {
        if isSignedIn { return true }
        sheet = auth.isAnonymous ? .signIn(reason: reason) : .setup
        return false
    }

    func refreshProfile() async { profile = try? await auth.fetchProfile() }
}
