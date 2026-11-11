import AuthenticationServices
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
    @Published var signInMessage: String?
    /// Apple only sends the name on first sign-in; kept for the setup sheet.
    private(set) var appleName: String?
    private var needsFresh = false
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
        #if DEBUG  // screenshots: -authSheet signIn|setup
        switch UserDefaults.standard.string(forKey: "authSheet") {
        case "signIn": sheet = .signIn(reason: "Save your progress and keep what helps you")
        case "setup": sheet = .setup
        default: break
        }
        #endif
    }

    func panicGate() -> PanicGate { .decide(usesSoFar: panicUses.value, signedIn: isSignedIn) }

    func recordPanicStart() { if !isSignedIn { panicUses.increment() } }

    /// True when signed in; otherwise opens sign-in (or setup if Apple is linked but no profile yet).
    func requireSignIn(reason: String) -> Bool {
        if isSignedIn { return true }
        sheet = auth.isAnonymous ? .signIn(reason: reason) : .setup
        return false
    }

    /// Handles the Apple button result: link (or fresh sign-in), then profile or setup.
    func completeApple(_ result: Result<ASAuthorization, Error>, rawNonce: String) async {
        guard case .success(let a) = result, let c = a.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = c.identityToken, let token = String(data: tokenData, encoding: .utf8) else { return }
        // ponytail: c.authorizationCode is needed for Apple token revocation on delete; stored in project 2.
        if let n = c.fullName, let given = n.givenName { appleName = given }
        do {
            if needsFresh { try await auth.signInFresh(idToken: token, nonce: rawNonce) }
            else { try await auth.signInWithApple(idToken: token, nonce: rawNonce) }
            needsFresh = false; signInMessage = nil
            profile = try await auth.fetchProfile()
            sheet = profile == nil ? .setup : nil
        } catch AuthError.needsFreshSignIn {
            needsFresh = true
            signInMessage = "This Apple ID already has an Ebb account. Tap the button again to sign in to it."
        } catch {
            signInMessage = "Sign in didn't work. Check your connection and try again."
        }
    }

    func refreshProfile() async { profile = try? await auth.fetchProfile() }
}
