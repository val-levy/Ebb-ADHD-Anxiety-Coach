# Ebb Chat Companion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A cloud chat in Reflect that turns free text into structured logs and replies with patterns and grounded wellness suggestions — never medical claims or medication advice — plus weekly insights, a daily plan and an evening check-in.

**Architecture:** iPhone → Supabase Edge Function `chat` (caller's JWT, RLS applies) → Claude (`claude-opus-5-5`, structured output) → guard (regex + `claude-haiku-5-5` judge, one rewrite, template fallback) → `log_entries` + `chat_messages` via one RPC. Patterns are computed in SQL (`compute_patterns`), Claude only phrases them. iOS: `ChatService` → `ChatStore` → views.

**Tech Stack:** Supabase Postgres (pgTAP, pg_cron), Edge Functions (Deno, `npm:@anthropic-ai/sdk`, `npm:@supabase/supabase-js@2`), SwiftUI iOS 17, supabase-swift `functions.invoke`.

**Spec:** `.claude/docs/chat-companion-design.md`

**Prerequisite:** the accounts plan (`2026-11-10-accounts.md`) is merged — chat requires a non-anonymous user.

## Global Constraints

- Wording rules: `.claude/docs/wording-and-safety.md` (source of truth). The AI may suggest wellness actions as options ("want to try…?", "might help"), grounded only in `compute_patterns` rows or `user_tuning` values. Never: condition names as claims, diagnosis phrasing, medication advice of any kind (incl. reminders), cardiac terms, accuracy claims. Patterns say "alongside / on the same days / more often when", never "because / causes".
- Doctor mention allowed only when the context pack flags an out-of-range metric (wording-and-safety.md §3).
- Models: `claude-opus-5-5` for chat and insight phrasing (thinking `{type:"adaptive"}`, `output_config.effort: "medium"`), `claude-haiku-5-5` for crisis screen and guard judge. Use exact IDs, no date suffix. No `temperature`. No forced `tool_choice` (400 on Opus 5.5) — use `output_config.format` JSON schema.
- Refusal fallback on Opus calls: `betas: ["server-side-fallback-2026-07-01"]`, `fallbacks: "default"`; check `stop_reason` (`refusal`, `max_tokens`) before reading content.
- `ANTHROPIC_API_KEY` only in Supabase secrets. Never in the app, the repo, or Config.xcconfig. Never commit Config.xcconfig or any key.
- System prompt is frozen text with `cache_control: {type:"ephemeral"}`; the per-user context pack goes in the user turn, never in `system`. No timestamps in `system`.
- Log kinds: exactly the 15 in spec §5.2. Entry `confidence < 0.6` → `status = 'needs_clarification'`.
- Limits: user message ≤ 4000 chars; 60 messages/user/day; 8/min. Reply ≤ 600 chars.
- Crisis (`possible`/`clear` or keyword hit) → no AI text; fixed app card with 988 call (`tel:988`) and text (`sms:988`).
- All new tables: own-row RLS `for all to authenticated`, writes also require `not coalesce((auth.jwt()->>'is_anonymous')::boolean,false)`, `on delete cascade` from `auth.users`.
- iOS per CLAUDE.md: one type per file, no logic in views, clay style, `ClayFont.*`, Reduce Motion respected, native TabView untouched; every simulator rebuild also builds/installs/launches on the iPhone.
- Commit small and often, one commit per step group, detailed messages; never push or deploy unless asked. Progress in `.claude/progress/chat-companion/progress.md` (real time from `date`) after each task. Update `.claude/docs/roadmap.md` when status changes.

## Review Focus

- Message mentions "meds" with 2+ active medications: entry saved with `medication_id = null`, `needs_clarification`, reply asks which one, quick-reply chips list names; picking one updates that entry, creates no new one.
- Claude returns a reply containing "take your meds earlier" or "this looks like an anxiety attack": guard catches it, one rewrite, and if still caught the template fallback is shown — the user never sees it (test with a stubbed model). A plain wellness suggestion ("want a 2-minute reset at 3?") is not touched.
- Anthropic API down / 5xx / refusal: user message is still stored, entries empty, reply is the fixed "Ebb couldn't reply just now — your message is saved." and the crisis keyword check still ran.
- Relative times across midnight and DST ("last night" sent at 00:30; a message on the DST switch day) resolve to the right local date using the sent `tz`.
- Offline send on iOS: message queued with "will send" tag, sent once on reconnect, never duplicated (client-generated message id is the idempotency key).

---

### Task 1: Data migration (tables, enum, RLS, rpc)

**Files:**
- Create: `supabase/migrations/20261110000400_chat_companion.sql`
- Test: `supabase/tests/chat_companion_test.sql`

**Interfaces:**
- Produces tables per spec §5.3: `medications`, `chat_threads`, `chat_messages`, `log_entries`, `insights`, `health_daily`, `chat_usage(id, user_id, message_id, model, input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, created_at)`.
- Produces enum `log_kind` with the 15 kinds, in spec order.
- Produces `chat_messages.id` supplied by the client (uuid) for idempotency: `insert … on conflict (id) do nothing`.
- Produces `rpc save_turn(p_thread uuid, p_assistant jsonb, p_entries jsonb) returns setof log_entries` — `security invoker`, inserts the assistant message + entries in one transaction, returns inserted entries.
- Produces `rpc messages_today() returns int` and `messages_last_minute() returns int` (counts own `role='user'` rows).

- [ ] **Step 1: Write pgTAP tests:** user B can't select A's rows in each of the 7 tables; anonymous JWT insert into `log_entries`/`chat_messages`/`medications` fails; `medications.name` of 61 chars fails; `log_entries.kind = 'foo'` fails; `save_turn` with 2 entries returns 2 rows and one assistant message; duplicate `chat_messages.id` insert leaves 1 row; deleting the auth user cascades all rows to 0.
- [ ] **Step 2: Run** `supabase test db`. Expected: FAIL (relations missing).
- [ ] **Step 3: Write the migration.** `health_daily` with `create table if not exists` (shared with personal model). Indexes: `log_entries (user_id, occurred_at desc)`, `chat_messages (thread_id, created_at)`, `insights (user_id, created_at desc)`.
- [ ] **Step 4: Run** `supabase db reset && supabase test db`. Expected: PASS. Also run `supabase/tests/rls.sh` — still PASS.
- [ ] **Step 5: Commit** (`feat(db): chat companion tables, log_kind enum, own-row RLS, save_turn rpc`). Log progress.

### Task 2: Pattern library in SQL

**Files:**
- Create: `supabase/migrations/20261110000500_compute_patterns.sql`
- Test: `supabase/tests/compute_patterns_test.sql`

**Interfaces:**
- Produces: `compute_patterns(p_user uuid, p_window_days int default 28) returns table(id text, kind text, label_a text, label_b text, n_with int, n_without int, value_with real, value_without real, window_days int, strength real)` — `security definer`, `set search_path = public`, first line `if p_user <> auth.uid() and current_user <> 'service_role' then raise exception 'forbidden'`.
- The 10 pattern ids from spec §7.1. Minimum-data rule: `n_with >= 6 and n_without >= 6`. Starting thresholds: sleep minutes ±30; sleep quality ±0.7; anxiety/focus/energy ±1.5; mood valence ±0.6; resets/day ±0.5; intensity drop ±1.0. `strength = abs(value_with - value_without) / threshold`.
- `med_time__focus` and `missed_med__next_sleep` use `medications.schedule` + `medication_taken`/`medication_missed` entries.

- [ ] **Step 1: Write pgTAP tests with seeded fixtures:** 14 days, missed-dose days have sleep 300 min vs 450 → `missed_med__next_sleep` returns with `value_with≈300, value_without≈450`; same fixture with only 5 missed days → that id absent; differences below threshold → absent; user A calling with B's id → exception.
- [ ] **Step 2: Run** `supabase test db`. Expected: FAIL.
- [ ] **Step 3: Implement** each pattern as one CTE over per-day aggregates (`date_trunc('day', occurred_at at time zone <user tz>)` — store user tz on `profiles.timezone text default 'UTC'`, add the column in this migration).
- [ ] **Step 4: Run** tests. Expected: PASS.
- [ ] **Step 5: Commit** (`feat(db): compute_patterns with minimum-data rule and 10 patterns`). Log progress.

### Task 3: Shared function code — schemas, prompt, guard

**Files:**
- Create: `supabase/functions/_shared/logKinds.ts`, `supabase/functions/_shared/prompt.ts`, `supabase/functions/_shared/guard.ts`, `supabase/functions/_shared/claude.ts`
- Test: `supabase/functions/_shared/guard_test.ts`, `supabase/functions/_shared/logKinds_test.ts`

**Interfaces:**
- `logKinds.ts`: `export const LOG_KINDS` (15 strings); `export const turnSchema` (JSON schema of spec §6.2, `data` as `oneOf` per kind, `additionalProperties:false` everywhere); `export function validateEntry(e: unknown): ValidEntry | null`.
- `prompt.ts`: `export const SYSTEM_PROMPT: string` (frozen); `export function contextPack(ctx: UserContext): string` — includes `PATTERNS`, `TUNING` (from `user_tuning` when present) and `OUT_OF_RANGE` (metrics with `isUnusual` for ≥ 3 consecutive days vs the user's own baseline, else empty).
- `guard.ts`: `export function regexHits(text: string, opts: {medNames: string[], outOfRange: boolean}): string[]`; `export async function judge(client: Anthropic, text: string): Promise<{medical_claim: boolean, medication_advice: boolean, span: string | null}>`; `export async function guardReply(client, reply, entries, rewrite: (r: string) => Promise<string>): Promise<{text: string, result: "pass"|"rewritten"|"fallback"}>`; `export function templateReply(entries: ValidEntry[]): string`.
- `claude.ts`: `export function client(): Anthropic` (reads `Deno.env.get("ANTHROPIC_API_KEY")`); `export const CHAT_MODEL = "claude-opus-5-5"`, `JUDGE_MODEL = "claude-haiku-5-5"`.

`SYSTEM_PROMPT` must contain wording-and-safety.md §1–§4 (summarized, not linked), then: role ("You are a calm, warm wellness coach who is good with numbers. You keep a log for one person, point out patterns in their own data, and may offer small wellness suggestions as options. You are not a therapist or doctor."); output contract; kind guide with level mappings ("a bit"→3, "really"→7, "through the roof"→9, "barely slept"→quality 1); time resolution against the sent local time; "only cite patterns from the PATTERNS list and values from TUNING, with their numbers; never compute your own; every suggestion must come from one of them"; "suggestions are options: 'want to try…?', 'might help', never orders"; "never mention medication except to restate what the user logged or a pattern about their own timing"; "never name a condition as something you detect or that the user has"; "mention a doctor only if OUT_OF_RANGE is set, and only with the exact wording given"; pronoun rule (none unless given); and these ❌→✅ pairs:

| ❌ Forbidden | ✅ Allowed |
|---|---|
| "Take your meds earlier." | "Logged: dose at 1pm. On days you logged it after noon, you slept 50 min less." |
| "Time to take your medication." | (nothing — Ebb never reminds about meds) |
| "This looks like an anxiety attack." | "Logged: anxiety 8. Want a 60-second reset?" |
| "You're sleep deprived, which worsens your ADHD." | "You slept 5h 20m, under your usual 7h. Want an earlier bedtime tonight, around 11:15?" |
| "Missing your meds causes your bad sleep." | "On the 4 days with a missed dose, the following night's sleep was rated lower (2.1 vs 3.6)." |
| "Caffeine is causing your anxiety." | "On days with coffee after 2pm you slept 40 min less. Want a 2pm cutoff reminder?" |
| "Your heart rhythm looks irregular." | "Your resting heart rate's been well above your usual for 4 days. If you feel unwell, consider checking in with a doctor." (only with OUT_OF_RANGE) |
| "You should go to bed at 10." (order) | "Your best days followed ~7h 40m of sleep. Bedtime around 11:15 might help." |
| "A walk will fix the anxiety." | "On days you logged a walk, anxiety logs averaged 3.2; other days 5.9. Want to fit one in?" |
| "Ebb detected a panic attack." | "Heart rate's up while you're sitting still. Breather?" |
| "Great job taking your meds!" (praise for compliance) | "Logged: took Lexapro at 9pm." |
| "Drink more water, it's good for ADHD." (generic, ungrounded) | (nothing — not from their patterns) |

- [ ] **Step 1: Write `guard_test.ts`** (`deno test`): `regexHits` flags each ❌ line above and none of the ✅ lines (✅ doctor line passes with `outOfRange:true`, fails with `false`); named cases: `"try a 2-minute reset at 3pm"` → `[]`; `"take your meds earlier"` → hit (medication advice); `"skip the Adderall tomorrow"` with `medNames:["Adderall"]` → hit; `"this looks like an anxiety attack"` → hit (diagnosis); `"consider checking in with a doctor"` → `[]` with `outOfRange:true`, hit with `false`; `"detects stress with 95% accuracy"` → hit; `"irregular heartbeat"` → hit; `"on days you logged your dose after noon, you slept 50 min less"` → `[]` (own pattern, no advice verb); `templateReply([missed Adderall, sleep q2])` === `"Logged: missed dose — Adderall, rough night."`; `guardReply` with a stubbed judge returning `medical_claim:true` twice → `result:"fallback"`, text === template; `medication_advice:true` then all false → `"rewritten"`; judge all false on `"want to try a reset at 3?"` → `"pass"`.
- [ ] **Step 2: Write `logKinds_test.ts`:** valid `medication_missed` passes; unknown kind → null; `anxiety.level = 11` → null; extra field → null.
- [ ] **Step 3: Run** `deno test supabase/functions/_shared`. Expected: FAIL.
- [ ] **Step 4: Implement.** Judge call: `messages.create({model: JUDGE_MODEL, max_tokens: 300, output_config: {format: {type:"json_schema", schema:{medical_claim:boolean, medication_advice:boolean, span:string|null}}}, …})`. Validate with the same JSON-schema validator for `validateEntry` (use `npm:ajv@8`; one dependency, already the standard).
- [ ] **Step 5: Run** tests. Expected: PASS.
- [ ] **Step 6: Commit** (one per file group: schemas; prompt; guard). Log progress.

### Task 4: Edge Function `chat`

**Files:**
- Create: `supabase/functions/chat/index.ts`, `supabase/functions/chat/crisis.ts`, `supabase/functions/chat/context.ts`
- Test: `supabase/functions/chat/index_test.ts`, `supabase/tests/chat_smoke.sh`

**Interfaces:**
- Consumes: Task 1 rpcs/tables, Task 2 `compute_patterns`, Task 3 modules.
- Produces HTTP: `POST /functions/v1/chat` body `{message_id: uuid, thread_id: uuid|null, text: string, client_sent_at: string, tz: string}` → 200 `{thread_id, reply: string|null, crisis: boolean, entries: [{id, kind, summary, status}], clarification: {question, options: string[], entry_id}|null, guard_result}`; 400 bad input; 403 anonymous; 429 `{error:"rate_limited", retry_after_s}`; 503 `{error:"model_unavailable"}` (message still saved).
- `crisis.ts`: `export const CRISIS_KEYWORDS: string[]`; `export async function crisisCheck(client, text): Promise<"none"|"possible"|"clear">` (keyword hit → `"clear"` without a model call; model errors → `"none"` only if no keyword hit).
- `context.ts`: `export async function buildContext(sb: SupabaseClient, userId: string, threadId: string): Promise<UserContext>` (spec §5.4: profile, meds, 14-day summary, patterns, last 30 messages).

Flow exactly as spec §6. Main call:

```ts
const res = await anthropic.beta.messages.create({
  model: CHAT_MODEL, max_tokens: 4000,
  thinking: { type: "adaptive" },
  output_config: { effort: "medium", format: { type: "json_schema", schema: turnSchema } },
  betas: ["server-side-fallback-2026-07-01"], fallbacks: "default",
  system: [{ type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } }],
  messages: [...history, { role: "user", content: contextPack(ctx) + "\n\nMESSAGE (" + client_sent_at + " " + tz + "):\n" + text }],
});
```

Clarification options: when the entry is a med kind and `medication_id` is null, `options` = active med names (server-built, not model-built).

- [ ] **Step 1: Write `index_test.ts`** with the Anthropic client injected as a stub: (a) "rough night, skipped meds" with one med → 2 entries, kinds `sleep_report` + `medication_missed`, med id filled; (b) two meds → `needs_clarification`, options = both names; (c) stub reply "Take your meds earlier." → guard path, reply contains no medication advice; (c2) stub reply "Want a 2-minute reset at 3pm?" → `guard_result:"pass"`, reply unchanged; (d) stub throws → 503 and user message row exists; (e) text "I want to end it all" → `crisis:true`, `reply:null`, no Opus call made; (f) 4001 chars → 400; (g) anonymous JWT → 403; (h) same `message_id` twice → one user row.
- [ ] **Step 2: Run** `deno test supabase/functions/chat`. Expected: FAIL.
- [ ] **Step 3: Implement** `index.ts` (Supabase client from the request's `Authorization` header — never the service role), `crisis.ts`, `context.ts`. Record `usage` into `chat_usage`.
- [ ] **Step 4: Run** unit tests. Expected: PASS.
- [ ] **Step 5: Write `chat_smoke.sh`** (like `rls.sh`): signs up a user, inserts a profile + one medication, calls the function with "rough night, skipped meds", asserts 2 entries and `regexHits(reply, …)` is empty. Run locally with `supabase functions serve --env-file supabase/.env.local` (gitignored; holds `ANTHROPIC_API_KEY`). Expected: PASS. (Costs a few cents — real API call.)
- [ ] **Step 6: Commit** (function; tests; smoke script). Log progress. Do **not** deploy.

### Task 5: Weekly insights function + cron

**Files:**
- Create: `supabase/functions/weekly-insights/index.ts`, `supabase/migrations/20261110000600_weekly_insights_cron.sql`
- Test: `supabase/functions/weekly-insights/index_test.ts`

**Interfaces:**
- Consumes: `compute_patterns`, `guard.ts`, `CHAT_MODEL`.
- Produces: `POST /functions/v1/weekly-insights` (service-role only; checks `Authorization` equals the service key) body `{tz_offset_hours: number}` → processes users whose `profiles.timezone` is currently Sunday 18:00±30min; inserts ≤ 3 `insights` rows each (`kind='weekly'`, `evidence` = the pattern row).
- Cron: `pg_cron` hourly job calling the function via `net.http_post` with the service key from Vault (`vault.decrypted_secrets`), never inline.

- [ ] **Step 1: Test:** stubbed patterns (3 rows) → 3 inserts with evidence; 0 rows → 1 insight `"Ebb needs about two more weeks of logs to see patterns."` only if no such row in the last 7 days; stubbed phrasing with a medical claim → guard fallback text = a deterministic sentence built from the pattern numbers (`"{label_a}: {value_with} on {n_with} days, {value_without} on {n_without} other days."`).
- [ ] **Step 2: Run.** Expected: FAIL. **Step 3: Implement.** **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit.** Log progress.

### Task 6: iOS models + ChatService

**Files:**
- Create: `apps/ios/Ebb/Core/Models/LogKind.swift`, `LogEntry.swift`, `ChatMessage.swift`, `ChatTurnResult.swift`, `Medication.swift`, `Insight.swift`
- Create: `apps/ios/Ebb/Core/Services/ChatService.swift`
- Modify: `apps/ios/Ebb/Core/Services/SupabaseService.swift` (expose `client` to services via an internal accessor, or add the methods there — follow whatever the accounts plan settled on for `AuthService`)

**Interfaces:**
- `enum LogKind: String, Codable, CaseIterable` (15 cases, raw values = SQL enum) with `var symbol: String` (SF Symbol) and `var title: String`.
- `struct LogEntry: Codable, Identifiable { id: UUID; kind: LogKind; summary: String; status: Status }`, `enum Status: String, Codable { case active, undone, needsClarification = "needs_clarification" }`.
- `struct ChatMessage: Codable, Identifiable { id: UUID; role: Role; body: String; entries: [LogEntry]; pending: Bool }`.
- `struct ChatTurnResult: Decodable` mirrors the function's 200 body.
- `struct Medication: Codable, Identifiable { id; name; doseText: String?; schedule: [Dose]; active: Bool }`, `struct Dose: Codable { time: String /* "HH:mm" */; days: [Int] }`.
- `final class ChatService { func send(_ text: String, messageId: UUID, threadId: UUID?) async throws -> ChatTurnResult; func history(thread: UUID) async throws -> [ChatMessage]; func undo(_ entry: UUID) async throws; func update(_ entry: UUID, data: [String: AnyJSON]) async throws; func medications() async throws -> [Medication]; func save(_ m: Medication) async throws; func insights() async throws -> [Insight]; func deleteChatHistory() async throws }`. `send` uses `client.functions.invoke("chat", options: .init(body: …))`, sends `TimeZone.current.identifier` and ISO-8601 with offset. Maps 429 → `ChatError.rateLimited(retryAfter:)`, 503 → `.unavailable`.

- [ ] **Step 1: Add `ChatService.selfCheck()` (DEBUG) asserts:** `ChatTurnResult` decodes the sample JSON from Task 4's interface (including `needs_clarification`); `LogKind.allCases.count == 15`; `Dose` round-trips `"08:00"`.
- [ ] **Step 2: Build + launch simulator.** Expected: assert fails (types missing → compile error counts as fail).
- [ ] **Step 3: Implement.** `xcodegen generate -q` after adding files.
- [ ] **Step 4: Build + launch simulator and iPhone.** Expected: no assert.
- [ ] **Step 5: Commit** (models; service). Log progress.

### Task 7: ChatStore + offline queue

**Files:**
- Create: `apps/ios/Ebb/Core/Stores/ChatStore.swift`, `apps/ios/Ebb/Core/Services/OutboxQueue.swift`

**Interfaces:**
- `@MainActor final class ChatStore: ObservableObject { @Published messages: [ChatMessage]; @Published isTyping: Bool; @Published crisisShowing: Bool; @Published clarification: Clarification?; @Published error: ChatError?; func send(_ text: String); func answerClarification(_ option: String); func undo(_ entry: LogEntry); func loadThread() async }`.
- Thread rule: reuse the last thread if its last message is < 6h old, else `threadId = nil` (server creates one).
- `OutboxQueue`: UserDefaults-backed `[PendingMessage(id, text, sentAt, tz)]`; `NWPathMonitor` flushes in order on reconnect; the same `message_id` is reused on retry (server idempotency).
- Answering a clarification sends the option text as a normal message with `clarifies: entry_id` (add `clarifies: uuid|null` to the function body in this task; server updates that entry instead of creating a new one — add a test case to Task 4's `index_test.ts`).

- [ ] **Step 1: `ChatStore.selfCheck()` asserts** with a stub service: send appends a pending user message immediately; success replaces it with entries attached; `crisis:true` sets `crisisShowing` and appends no assistant bubble; offline → message stays `pending` and is in the outbox; flush sends once.
- [ ] **Step 2: Build.** Expected: FAIL. **Step 3: Implement.** **Step 4: Build + launch sim + iPhone.** Expected: PASS.
- [ ] **Step 5: Commit.** Log progress.

### Task 8: Chat UI in Reflect

**Files:**
- Create: `apps/ios/Ebb/Features/Reflect/ReflectSection.swift` (`enum ReflectSection { case chat, patterns, dump }`), `Features/Reflect/Chat/ChatView.swift`, `ChatBubble.swift`, `EntryChip.swift`, `EntryEditSheet.swift`, `ClarificationChips.swift`, `ChatComposer.swift`, `TypingDots.swift`, `CrisisCard.swift`, `ChatPrivacySheet.swift`
- Modify: `apps/ios/Ebb/Features/Reflect/ReflectView.swift` (segmented `Picker` Chat · Patterns · Dump; today's content becomes Dump), `EbbApp.swift` (inject `ChatStore`)

**Copy (fixed, app UI):**
- Empty state: "Tell Ebb how things are going. It'll keep track."
- Privacy sheet (first open, `@AppStorage("chatPrivacySeen")`): "Your messages and logs are saved in your Ebb account and sent to Anthropic's Claude to write replies. Anthropic doesn't train on them. You can delete your chat history any time in Settings." Button: "Got it".
- Crisis card: "You don't have to go through this alone. If you're in danger or thinking about ending your life, you can call or text 988 any time." Buttons: Call 988, Text 988. Footer: "You can keep logging whenever you want."
- Offline tag: "will send when online". Rate limit: "That's a lot for today — Ebb will be ready again tomorrow."
- Unavailable: "Ebb couldn't reply just now — your message is saved."

- [ ] **Step 1:** Build views (clay bubbles: user right `Theme.accent` tint, Ebb left with mascot face; chips under user bubble; tap chip → `EntryEditSheet` with Undo; composer counter appears at 3,500; `TypingDots` static under Reduce Motion). Views only read `ChatStore`.
- [ ] **Step 2: Build + launch sim + iPhone.** Manually verify on device: send "rough night, skipped meds" (against local functions) → 2 chips; undo one → chip greys; swipe on Reflect still moves tabs; segmented control switches sections.
- [ ] **Step 3: Commit** (one per view group). Log progress.

### Task 9: Patterns view + Medications screen + Settings

**Files:**
- Create: `Features/Reflect/Patterns/PatternsView.swift`, `InsightCard.swift`, `EvidenceSheet.swift`; `Features/Profile/Medications/MedicationsView.swift`, `MedicationEditor.swift`
- Modify: `ProfileView.swift` (Medications row), `SettingsView.swift` ("Delete chat history" with confirm — a destructive button using `.confirmationDialog`, not an alert)

**Interfaces:**
- `EvidenceSheet` renders `Insight.evidence` as sentences: "{label_a}: {value_with} on {n_with} days vs {value_without} on {n_without} days, last {window} days."
- Medications editor: name (≤60), dose text (≤40), times (multiple `DatePicker(.hourAndMinute)`), weekdays; optional "kicks in after" / "wears off around" (minutes; used by the personal model, stored in `schedule` items as `onset_min`, `wear_off_min`).
- Empty patterns state: "Ebb needs about two more weeks of logs to see patterns." Medications helper text (app UI, allowed): "Add your medications so Ebb understands things like 'the morning one'."

- [ ] **Step 1:** Implement; `MedicationEditor` validation lives in `Medication.validate() -> [String]` with a DEBUG `selfCheck` (61-char name → error; no times → error).
- [ ] **Step 2: Build + launch sim + iPhone;** verify add/edit med, insight card shows evidence, delete chat history empties the chat.
- [ ] **Step 3: Commit.** Log progress.

### Task 10: Daily plan

**Files:**
- Create: `supabase/functions/daily-plan/index.ts`, `supabase/functions/daily-plan/plan.ts`, `apps/ios/Ebb/Features/Reflect/Chat/DailyPlanCard.swift`
- Test: `supabase/functions/daily-plan/plan_test.ts`

**Interfaces:**
- Consumes: `user_tuning` (personal-model Task 1; if absent, the function returns `{plan:null}`), latest `health_daily`, `compute_patterns` row `caffeine_after_14__sleep`, `guard.ts`, `CHAT_MODEL`.
- `plan.ts`: `export function planItems(t: UserTuning | null, lastNight: HealthDay | null, caffeine: PatternRow | null): PlanItems` — pure; `PlanItems = {bedtime?: "HH:mm", windDown?: "HH:mm" /* bedtime − 45 min */, resetAt?: "HH:mm", caffeineCutoff?: "HH:mm" /* only if the pattern row exists */, shortNight?: {slept_min: number, usual_min: number}}`; each field present only when its source exists.
- `POST /functions/v1/daily-plan` (caller JWT, non-anonymous) → `{plan: string|null, items: PlanItems}`; at most one `insights` row per user per local day (`kind='daily_plan'`, `evidence` = items); second call same day returns the stored row without a model call.
- Claude gets `items` as JSON and phrases ≤ 4 lines, options framing; guard as chat. Fallback = deterministic lines from `items` ("Bedtime target tonight: 23:15. Wind-down at 22:30.").
- iOS: `ChatStore.loadDailyPlan()` on first Reflect open after `user_tuning` wake time; `DailyPlanCard` pinned above the chat.

- [ ] **Step 1: Test `plan_test.ts`:** null tuning → `{}`; tuning bedtime 23:15 → `windDown === "22:30"`; no caffeine row → no `caffeineCutoff`; last night 5h vs usual 7h → `shortNight` set; same-day second call → no model call (stub counts calls); stub phrasing "take your meds before bed" → fallback text.
- [ ] **Step 2: Run** `deno test supabase/functions/daily-plan`. Expected: FAIL. **Step 3: Implement.** **Step 4: Run.** Expected: PASS.
- [ ] **Step 5:** sim + iPhone: card shows with seeded tuning; hidden with none. **Step 6: Commit.** Log progress.

### Task 11: Evening check-in

**Files:**
- Create: `apps/ios/Ebb/Core/Services/EveningCheckIn.swift`
- Modify: `NudgeScheduler.swift` (personal-model Task 6; if not built yet, create the minimal scheduler here and note it in the ledger)

**Interfaces:**
- `enum EveningCheckIn { static func shouldFire(now: Date, wake: Date, sleepNeedMin: Int, latencyMin: Int, alreadyAsleep: Bool) -> Bool /* true when now + latency + sleepNeed > wake */ }`.
- Scheduled at the wind-down time from `TuningStore`; at fire time a notification service check calls `shouldFire`; request id `"evening-checkin"`; respects quiet windows, nudge cap, Personalize toggle; skipped when no bedtime target.
- Copy (fixed, app UI): title "Heading toward a short night", body "Want to start winding down?" Action opens a wind-down calm session. Never mentions medication or a condition.

- [ ] **Step 1: `EveningCheckIn.selfCheck()`:** 23:30, wake 07:00, need 480, latency 15 → true; 22:00 same → false; `alreadyAsleep` → false; no bedtime target → not scheduled.
- [ ] **Step 2–4:** fail → implement → sim + iPhone pass (DEBUG override fires it 2 min ahead).
- [ ] **Step 5: Commit.** Log progress.

### Task 12: Docs and records

**Files:**
- Modify: `.claude/docs/roadmap.md` (chat companion → "in progress"/"built (local)"; privacy decision → resolved: cloud), `.claude/docs/phase-2-personalization.md` (link this spec/plan), `.claude/docs/product-spec.md` (note superseding "no server"), `.claude/docs/built-so-far.md`, `CLAUDE.md` (link wording-and-safety.md; already done 2026-11-10, just verify).

- [ ] **Step 1:** Edit docs. **Step 2: Commit** (`docs: chat companion status, cloud privacy decision`). Log progress.
- [ ] **Step 3:** Ask the user before `supabase functions deploy chat weekly-insights daily-plan` and `supabase secrets set ANTHROPIC_API_KEY` on the hosted project.
