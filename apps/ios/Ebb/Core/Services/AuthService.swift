import Foundation
import Supabase

enum AuthError: Error { case needsFreshSignIn }

/// The only code that touches `client.auth`. Anonymous until the user signs in with Apple.
final class AuthService {
    static let shared = AuthService()
    private let supabase = SupabaseService.shared
    private var client: SupabaseClient { supabase.client }

    func ensureSignedIn() async throws { try await supabase.ensureSignedIn() }

    var userId: UUID? { client.auth.currentUser?.id }
    var isAnonymous: Bool { client.auth.currentUser?.isAnonymous ?? true }

    /// Links Apple to the current anonymous user so their history carries over.
    func signInWithApple(idToken: String, nonce: String) async throws {
        guard isAnonymous, client.auth.currentSession != nil else { return try await signInFresh(idToken: idToken, nonce: nonce) }
        do {
            try await client.auth.linkIdentityWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        } catch let e as Supabase.AuthError where e.errorCode == .identityAlreadyExists {
            throw AuthError.needsFreshSignIn   // Apple ID already has an account; tokens are single-use
        }
    }

    func signInFresh(idToken: String, nonce: String) async throws {
        _ = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
    }

    func fetchProfile() async throws -> Profile? {
        guard let id = userId else { return nil }
        let rows: [Profile] = try await client.from("profiles").select().eq("id", value: id).limit(1).execute().value
        return rows.first
    }

    func createProfile(_ p: Profile) async throws { try await client.from("profiles").insert(p).execute() }

    func updateProfile(_ p: Profile) async throws {
        try await client.from("profiles").update(p).eq("id", value: p.id).execute()
    }

    func isAvailable(username: String) async throws -> Bool {
        try await client.rpc("username_available", params: ["name": username]).execute().value
    }

    func signOut() async throws {
        try await client.auth.signOut()
        _ = try await client.auth.signInAnonymously()
    }

    func deleteAccount() async throws {
        try await client.functions.invoke("delete-account")
        try await signOut()
    }
}
