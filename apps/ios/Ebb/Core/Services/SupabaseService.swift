import Foundation
import Supabase

/// All network access to Supabase. Views never talk to the backend directly.
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient  // internal: AuthService needs auth + functions

    private init() {
        let info = Bundle.main.infoDictionary!
        client = SupabaseClient(supabaseURL: URL(string: info["SUPABASE_URL"] as! String)!,
                                supabaseKey: info["SUPABASE_ANON_KEY"] as! String)
    }

    /// Anonymous session = no signup screen, but RLS still scopes rows to this install.
    /// Single-flight: launch calls this from several stores at once; without sharing one task each
    /// caller would create its own anonymous user.
    @MainActor func ensureSignedIn() async throws {
        if client.auth.currentSession != nil { return }
        if let pending = signingIn { return try await pending.value }
        let task = Task { _ = try await client.auth.signInAnonymously() }
        signingIn = task
        defer { signingIn = nil }
        try await task.value
    }
    @MainActor private var signingIn: Task<Void, Error>?

    func resets(since date: Date) async throws -> [ResetEntry] {
        try await client.from("resets").select("kind,helped,created_at")
            .gte("created_at", value: date).execute().value
    }

    var currentUserId: UUID? { client.auth.currentUser?.id }

    /// nil when the user has no note yet (or is anonymous: RLS returns nothing).
    func note() async throws -> Note? {
        let rows: [Note] = try await client.from("notes").select("body,updated_at").limit(1).execute().value
        return rows.first
    }

    func save(_ note: Note) async throws {
        guard client.auth.currentUser?.isAnonymous == false else { return }
        try await client.from("notes").upsert(note, onConflict: "user_id").execute()
    }

    func insert(_ entry: ResetEntry) async throws {
        try await client.from("resets").insert(entry).execute()
    }

    func nudgeEvents(since date: Date) async throws -> [NudgeEvent] {
        try await client.from("nudge_events")
            .select("id,origin,outcome,created_at")
            .gte("created_at", value: date).execute().value
    }

    func insert(_ event: NudgeEvent) async throws -> NudgeEvent {
        try await client.from("nudge_events").insert(event).select().single().execute().value
    }

    func setNudgeOutcome(id: UUID, outcome: NudgeOutcome) async throws {
        try await client.from("nudge_events").update(["outcome": outcome.rawValue])
            .eq("id", value: id.uuidString).execute()
    }

    func recentCalmSessions(limit: Int = 30) async throws -> [CalmSession] {
        try await client.from("calm_sessions")
            .select("program,intensity_before,intensity_after,helped_technique,created_at")
            .order("created_at", ascending: false).limit(limit).execute().value
    }

    func insert(_ session: CalmSession) async throws {
        try await client.from("calm_sessions").insert(session).execute()
    }
}
