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

    /// One page, newest first. `before` is the keyset cursor (created_at of the last row seen), so deep pages stay on the index.
    func brainDumps(before: Date? = nil, limit: Int = 20) async throws -> [BrainDump] {
        let query = client.from("brain_dumps").select("id,body,created_at")
        return try await (before.map { query.lt("created_at", value: $0) } ?? query)
            .order("created_at", ascending: false).limit(limit).execute().value
    }

    func insert(_ dump: BrainDump) async throws {
        try await client.from("brain_dumps").insert(dump).execute()
    }

    func deleteBrainDump(id: UUID) async throws {
        try await client.from("brain_dumps").delete().eq("id", value: id).execute()
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

    func logs(since date: Date) async throws -> [LogEntry] {
        try await client.from("life_logs").select("kind,tag,source,created_at")
            .gte("created_at", value: date).execute().value
    }

    func insert(_ log: LogEntry) async throws {
        try await client.from("life_logs").insert(log).execute()
    }
}
