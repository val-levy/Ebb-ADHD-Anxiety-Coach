import AuthenticationServices
import Foundation

enum AuthSheet: Identifiable {
    case signIn(reason: String), setup
    var id: String { if case .signIn(let r) = self { return "signIn:\(r)" }; return "setup" }
}

/// Who is signed in, which auth sheet is up, and the panic-ladder decision.
@MainActor
final class SessionStore: ObservableObject {
    @Published var profile: Profile? {
        // MascotPeek / TipCoach read this key; keep it in step with the account.
        didSet { if let a = profile?.animal { UserDefaults.standard.set(a.rawValue, forKey: "profileAnimal") } }
    }
    @Published var sheet: AuthSheet?
    @Published var signInMessage: String?
    /// Apple only sends the name on first sign-in; kept for the setup sheet.
    private(set) var appleName: String?
    private var needsFresh = false
    /// Shown instead of a panic session once the anonymous ladder is used up.
    @Published var panicBlocked = false
    /// A sheet to open once the blocked cover finishes closing (SwiftUI drops sheets presented mid-dismiss).
    var queuedSheet: AuthSheet?
    func showQueuedSheet() { sheet = queuedSheet; queuedSheet = nil }
    /// "Not now" on the before-panic prompt: starts the session it interrupted.
    private(set) var skipAction: (() -> Void)?
    private var promptAfterPanic = false
    var isSignedIn: Bool { profile != nil }

    let auth: AuthService
    private let panicUses = KeychainCounter(key: "panicUses")

    init(auth: AuthService = .shared) { self.auth = auth }

    /// Never blocks: offline launch leaves profile nil and the panic ladder runs from the Keychain.
    func start() async {
        do {
            try await auth.ensureSignedIn()
            profile = try await auth.fetchProfile()
        } catch {}  // keep whatever we had; offline must not look like signed out
        #if DEBUG  // screenshots: -authSheet signIn|setup
        switch UserDefaults.standard.string(forKey: "authSheet") {
        case "signIn": sheet = .signIn(reason: "Save your progress and keep what helps you")
        case "setup": sheet = .setup
        case "blocked": panicBlocked = true
        default: break
        }
        #endif
    }

    /// Apple-linked (local session, works offline) means panic is always free, profile or not.
    private var hasAccount: Bool { !auth.isAnonymous }
    func panicGate() -> PanicGate { .decide(usesSoFar: panicUses.value, signedIn: hasAccount) }

    /// Sign-in for anonymous users; setup if Apple is linked but there's no profile yet.
    func authSheet(reason: String) -> AuthSheet { auth.isAnonymous ? .signIn(reason: reason) : .setup }

    /// Runs the panic ladder for a tap on "I'm panicking". `start` actually opens the session.
    func panicTapped(start: @escaping () -> Void) {
        let begin = { [weak self] in self?.recordPanicStart(); start() }
        switch panicGate() {
        case .free: begin()
        case .promptAfter: promptAfterPanic = true; begin()
        case .promptBeforeSkippable:
            skipAction = { [weak self] in self?.sheet = nil; self?.skipAction = nil; begin() }
            sheet = authSheet(reason: "Sign in to keep using panic help anytime")
        case .blocked: panicBlocked = true
        }
    }

    func panicSessionEnded() {
        guard promptAfterPanic else { return }
        promptAfterPanic = false
        if !isSignedIn { sheet = authSheet(reason: "Glad you got through it. Sign in to keep panic help ready next time") }
    }

    func recordPanicStart() { if !hasAccount { panicUses.increment() } }

    /// True when signed in; otherwise opens sign-in (or setup if Apple is linked but no profile yet).
    func requireSignIn(reason: String) -> Bool {
        if isSignedIn { return true }
        sheet = authSheet(reason: reason)
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

    /// Optimistic edit: shows at once, rolls back if the save fails.
    func save(_ edited: Profile) async {
        let old = profile
        profile = edited
        do { try await auth.updateProfile(edited) } catch { profile = old }
    }

    func signOut() async {
        try? await auth.signOut()
        profile = nil
    }

    func deleteAccount() async -> Bool {
        do { try await auth.deleteAccount(); profile = nil; return true } catch { return false }
    }

    func refreshProfile() async { if let p = try? await auth.fetchProfile() { profile = p } }
}
