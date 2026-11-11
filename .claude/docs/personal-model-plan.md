# Ebb Personal Model Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Per-user personalization of reset length, breathing pace, daily meditation reminder time, nudge quiet windows, reset order and sleep targets (sleep need, wake time, bedtime), learned nightly from the user's own app, chat and Apple Health data.

**Architecture:** iOS `HealthSyncService` uploads daily HealthKit aggregates to `health_daily`. A nightly Edge Function `personalize` (pg_cron, 03:30 user-local) runs pure TypeScript estimators (robust baselines, med-phase labels, Beta/Thompson bandits, slot scoring) and writes one `user_tuning` row. iOS `TuningStore` reads it (UserDefaults cache) and existing stores and `NudgeScheduler` ask it instead of constants.

**Tech Stack:** HealthKit (read-only, background delivery), UserNotifications, SwiftUI iOS 17, Supabase Postgres + pg_cron + Vault, Edge Functions (Deno, no ML libraries).

**Spec:** `.claude/docs/personal-model-design.md`

**Prerequisites:** accounts plan merged; chat-companion Task 1 migration (creates `health_daily`, `medications`, `log_entries`). If this plan runs first, run that migration task first.

## Global Constraints

- No AI/LLM in this project: the model computes numbers, the chat phrases them. Never remind anyone to take medication; med times are context only.
- UI copy follows `.claude/docs/wording-and-safety.md`. Personalized UI may explain a reason in wellness terms ("You slept less than usual, so today's session is a bit longer."); never a condition name, diagnosis or cardiac term.
- Sleep targets: need = median sleep of nights before best-rated days (min 14 nights + 5 best days, default 480, bounds 360–600); wake = 28-day median `sleep_end` (min 10 nights; weekday/weekend split if > 60 min apart); bedtime = wake − need − latency (default 15). Move ≤ 15 min (times) / 10 min (need) per night. User-set values always win.
- Defaults until data minimums: baselines need 10 days of a metric; bandits need 8 rated sessions per context; per-phase baselines need 8 points per phase; slot scoring needs 14 days of app use.
- Grids: guided length {60,120,180,240,300,420} s; quick {60,90,120} s; pace {4.5,5,5.5,6,6.5} bpm, inhale:exhale 4:6.
- Bounds: length 60–600 s; pace 4–7 bpm; reminders 07:00–22:00 unless user-set; move at most one grid step and 45 min per night; elevated state never shortens a session.
- Bandit prior Beta(2,2) on current default; decay 0.97/day; exploration 1 in 5 sessions, max one step from default.
- Baselines: 28-day median + MAD, 7-day EWMA α=0.25; unusual = |x−median| > 1.5·MAD.
- Med phases from dose time t: pre (<t), onset (t…t+60m), active (+60m…+6h), wearing_off (+6h…+9h), off (>+9h or missed day); per-med `onset_min`/`wear_off_min` overrides.
- Slot score = 0.4·P(done ≤1h after reminder) + 0.3·helped-rate in that hour + 0.2·dip fit + 0.1·med-phase fit (0 until per-phase anxiety baseline exists).
- Stale > 14 days → revert to default over 7 days. Settings toggle + `personalization_enabled` server flag both disable everything.
- Only daily aggregates and per-session 3-number HR summaries leave the phone; never raw HealthKit samples.
- RLS own-row on all new tables; `personalize` uses the service role from Vault, invoked only by cron; never commit keys or Config.xcconfig.
- CLAUDE.md iOS rules (one type per file, no logic in views, clay, `ClayFont.*`, Reduce Motion, native TabView), rebuild sim + iPhone every time.
- Commit small and often; never push or deploy unless asked. Progress in `.claude/progress/personal-model/progress.md`. Update `.claude/docs/roadmap.md`.

## Review Focus

- User denies Health access, or grants only some types: app works on app-only data; missing metrics leave their baselines null and no estimator divides by zero or crashes.
- Night-shift sleeper (sleep 08:00–15:00): sleep window logic and reminder bounds don't schedule into their sleep; the 18:00→14:00 night window doesn't split their sleep into two days in a way that zeroes it.
- Traveller changes timezone: nightly run uses the profile tz at run time; reminders reschedule in the new local time, no double fire.
- Brand-new user with zero data: `personalize` writes a row equal to defaults with empty evidence; "Why this?" shows "Using defaults until Ebb learns more."
- Toggle off then on: values return to the last computed tuning, not defaults, and nothing fired while off.

---

### Task 1: Migration — tuning, nudge events, session metrics, cron

**Files:**
- Create: `supabase/migrations/20261110000700_personal_model.sql`
- Test: `supabase/tests/personal_model_test.sql`

**Interfaces:**
- `user_tuning` per spec §9 (pk `user_id`), read-only to its owner (select policy only; writes service role).
- `nudge_events(id, user_id, kind text check in ('meditation','detection'), fired_at, outcome text check in ('opened','snoozed','dismissed','ignored'), created_at)`.
- `session_metrics(id, user_id, source text check in ('reset','calm'), source_id uuid, duration_s int, pace_bpm real, hr_start real, hr_min real, hr_end real, created_at)`.
- `profiles.timezone` (added by chat Task 2 if not present: `add column if not exists`).
- `pg_cron` job `personalize-hourly`: `net.http_post` to `/functions/v1/personalize` with `{local_hour: 3}`, bearer from `vault.decrypted_secrets` name `service_role_key`.

- [ ] **Step 1: pgTAP:** owner can select own `user_tuning`, cannot insert/update; B can't see A's `nudge_events`/`session_metrics`; outcome `'foo'` rejected; cascade on user delete.
- [ ] **Step 2: Run** `supabase test db` → FAIL. **Step 3: Implement.** **Step 4:** `supabase db reset && supabase test db` → PASS.
- [ ] **Step 5: Commit.** Log progress.

### Task 2: Estimators (pure TypeScript)

**Files:**
- Create: `supabase/functions/personalize/baselines.ts`, `medPhase.ts`, `bandit.ts`, `slots.ts`, `quiet.ts`, `rails.ts`
- Test: one `*_test.ts` per file

**Interfaces:**
- `baselines.ts`: `robust(values: number[]): {median: number, mad: number} | null` (null if < 10); `ewma(values: number[], alpha = 0.25): number`; `isUnusual(x: number, b: {median, mad}): boolean`.
- `medPhase.ts`: `phaseAt(t: Date, doses: Date[], missed: boolean, onsetMin = 60, wearOffMin = 540): "pre"|"onset"|"active"|"wearing_off"|"off"`.
- `bandit.ts`: `type Arm = {value: number, a: number, b: number}`; `prior(grid: number[], defaultValue: number): Arm[]` (Beta(2,2) on default, Beta(1,1) others); `update(arms: Arm[], value: number, reward: number): Arm[]`; `decay(arms: Arm[], days: number, rate = 0.97): Arm[]` (shrinks toward Beta(1,1)); `best(arms): number` (highest mean); `rewardFor(s: {helped?: boolean, before?: number, after?: number, hrStart?: number, hrMin?: number}): number` (spec §6.2 formula).
- `slots.ts`: `candidateSlots(wake: string, sleepStart: string, busy: Interval[]): string[]` (15-min "HH:mm"); `score(slot, data): number`; `chooseReminder(prev: string|null, scored: Map<string,number>, shortSleep: boolean, userFixed: string|null): string`.
- `quiet.ts`: `quietWindows(sleepMedian: {start, end}, busy: Interval[], dismissByHour: Map<number,{n,dismissed}>): Interval[]`.
- `rails.ts`: `clampStep(prev: number, next: number, grid: number[]): number`; `clampMinutes(prev: string, next: string, max = 45): string`; `revertIfStale(value, def, lastPointAgeDays): number`.

- [ ] **Step 1: Tests:** `robust([..9 values])` null; median/MAD of `[1,2,3,4,100,…]` resistant to the outlier; `phaseAt` for each boundary (t+59m onset, t+60m active, t+9h off, missed → off); `update` with reward 1 raises the arm's mean; `decay(…, 30)` moves a strong arm toward 0.5; `best` after 10 rewards at 240 s returns 240; `rewardFor({helped:true})===1`, `rewardFor({before:8,after:4})===0.5`; `clampStep(120, 420, grid)===180`; `clampMinutes("15:00","13:00")==="14:15"`; `chooseReminder` never outside 07:00–22:00 and with `shortSleep` picks a morning slot; `userFixed` always wins; night-shift sleep median 08:00–15:00 → quiet window covers it and no candidate falls inside.
- [ ] **Step 2:** `deno test supabase/functions/personalize` → FAIL. **Step 3: Implement.** **Step 4:** → PASS.
- [ ] **Step 5: Commit** (one per estimator). Log progress.

### Task 2b: Sleep-target estimator

**Files:**
- Create: `supabase/functions/personalize/sleep.ts`
- Test: `supabase/functions/personalize/sleep_test.ts`

**Interfaces:**
- `type Night = {day: string, sleepMin: number, start: string, end: string, latencyMin?: number, weekend: boolean}`; `type DayScore = {day: string, score: number}` (mood/focus − anxiety + helped-rate, from `load.ts`).
- `sleepNeed(nights: Night[], scores: DayScore[], prev: number | null): number` — default 480 below minimums; bounds 360–600; ≤ 10 min move from `prev`.
- `wakeTime(nights: Night[], prev: {weekday: string, weekend: string} | null): {weekday: string, weekend: string}` — same value for both unless medians differ > 60 min; ≤ 15 min move.
- `bedtime(wake: string, needMin: number, latencyMin = 15): string` (wraps past midnight).
- `sleepTargets(nights, scores, prev, userSet: {wake?: string, bedtime?: string} | null): UserTuning["sleep"]` — user-set wins.
- Produces: `user_tuning.sleep` (design §9), consumed by chat `daily-plan` and `EveningCheckIn`.

- [ ] **Step 1: Tests:** 13 nights → need 480 (default); 20 nights where the best-day nights average 470 → 470 when `prev` 470, and from `prev` 480 → 470 (within 10), from `prev` 420 → 430 (clamped); need never < 360 or > 600; weekday wake 07:00 / weekend 08:30 → split; 10 weekday nights at 07:00 + 4 weekend at 07:30 → both `"07:00"` (overall median), no split; `bedtime("07:00", 480)` === `"22:45"`; `bedtime("06:00", 540, 30)` === `"20:30"`; night-shift wake 15:00 → bedtime 06:45, no crash; `userSet.wake = "06:30"` → returned wake is `"06:30"` regardless of data; no sleep data at all → `{need_min: 480, wake: null, bedtime: null}`.
- [ ] **Step 2:** `deno test supabase/functions/personalize/sleep_test.ts` → FAIL. **Step 3: Implement.** **Step 4:** → PASS.
- [ ] **Step 5: Commit.** Log progress.

### Task 3: Edge Function `personalize`

**Files:**
- Create: `supabase/functions/personalize/index.ts`, `load.ts`, `compute.ts`
- Test: `supabase/functions/personalize/compute_test.ts`

**Interfaces:**
- `load.ts`: `loadUser(sb, userId): Promise<UserData>` — 60 days of `health_daily`, `log_entries`, `resets`, `calm_sessions`, `session_metrics`, `nudge_events`, active `medications`, previous `user_tuning`, `profiles.timezone`.
- `compute.ts`: `computeTuning(d: UserData, now: Date): UserTuning` — pure; uses Task 2 and 2b modules; fills `evidence` per target with the exact numbers ("guided 240s: helped 9/11; 120s: 3/7"); `arms` carried forward.
- `index.ts`: POST, service key required; `{local_hour}` → users whose tz local hour == 3 now; for each: load → compute → upsert `user_tuning`; per-user try/catch so one failure doesn't stop the batch; logs ids + durations only (no health values).

- [ ] **Step 1: Tests with fixtures:** zero-data user → all defaults, `evidence` empty; 20 rated guided sessions favouring 300 s with prior default 180 → tuning moves to 240 (one step) not 300; elevated-state data never yields shorter length than calm; personalization_enabled false in previous row → row written with defaults and flag preserved; short-sleep night → reminder earlier but ≤ 45 min move… (note: short-sleep may move up to 2h per spec §6.3 — implement as: short-sleep override bypasses the 45-min daily rail but stays in bounds; test both).
- [ ] **Step 2:** FAIL → **Step 3:** implement → **Step 4:** PASS.
- [ ] **Step 5:** Local run: `supabase functions serve`, seed one user via a SQL snippet in `supabase/snippets/personal_model_seed.sql`, POST `{local_hour: <current>}` with the local service key, check the `user_tuning` row.
- [ ] **Step 6: Commit.** Log progress. Don't deploy.

### Task 4: iOS HealthKit sync

**Files:**
- Create: `apps/ios/Ebb/Core/Services/HealthSyncService.swift`, `Core/Models/HealthDay.swift`, `Core/Models/HealthAggregator.swift`
- Modify: `apps/ios/project.yml` (HealthKit capability, `com.apple.developer.healthkit` + background-delivery entitlement, `NSHealthShareUsageDescription` = "Ebb reads sleep, heart and breathing data to fit sessions and reminders to you. It never writes to Health."), `SupabaseService.swift` (`upsert(_ days: [HealthDay])`)

**Interfaces:**
- `struct HealthDay: Codable { day: String /* yyyy-MM-dd */; sleepMinutes, sleepStart, sleepEnd, sleepEfficiency, restingHr, hrvSdnnMs, respiratoryRate, spo2Avg, steps, activeKcal, mindfulMinutes (all optional) }`.
- `enum HealthAggregator { static func nightWindow(for day: Date, cal: Calendar) -> DateInterval /* 18:00 prev → 14:00 */; static func sleep(_ samples: [SleepSample], in w: DateInterval) -> (minutes: Int, start: Date?, end: Date?, efficiency: Double?); static func overnightMean(_ s: [(Date, Double)], day: Date) -> Double?; static func selfCheck() }`.
- `final class HealthSyncService { var isAuthorized: Bool; func requestAccess() async throws; func syncRecent(days: Int = 30) async; func startBackgroundDelivery() }` — anchors in UserDefaults per type; no-ops cleanly when Health is unavailable or denied.
- Free-team note: HealthKit works with a free provisioning profile on device; background delivery may need the paid account — guard it and log.

- [ ] **Step 1: `HealthAggregator.selfCheck()`:** stages asleepCore 23:00–03:00 + asleepREM 03:00–06:30 → 450 min, start 23:00, end 06:30; night-shift sleep 08:00–15:00 on day D → counted (window adjusts: if > 50% of asleep time falls outside the default window, use 18:00 D−1 → 18:00 D); overlapping samples from Watch + phone not double-counted (union of intervals); empty → nil fields.
- [ ] **Step 2:** build sim → assert fails. **Step 3:** implement. **Step 4:** build + launch sim + iPhone → PASS; on iPhone, connect Health and confirm a `health_daily` row locally.
- [ ] **Step 5: Commit.** Log progress.

### Task 5: Session metrics + TuningStore

**Files:**
- Create: `Core/Models/UserTuning.swift`, `Core/Stores/TuningStore.swift`, `Core/Services/SessionMetricsRecorder.swift`
- Modify: `ResetStore.swift`, `CalmStore.swift` (ask `TuningStore` for length/pace/order; record metrics at session end), `EbbApp.swift` (inject)

**Interfaces:**
- `struct UserTuning: Codable` mirrors `user_tuning`; `static let defaults`.
- `@MainActor final class TuningStore: ObservableObject { @Published tuning: UserTuning; var enabled: Bool (AppStorage "personalize"); func resetLength(_ kind: SessionKind, state: BodyState) -> TimeInterval; func breathingPace(state: BodyState) -> Double; func resetOrder(at: Date) -> [Reset.Kind]; var meditationReminder: DateComponents?; var quietWindows: [ClosedRange<Int>] /* minutes of day */; func load() async; func evidence(for: TuningTarget) -> [String]; func shouldExplore() -> Bool /* 1 in 5 */ }`.
- `BodyState` (`calm`/`elevated`) decided on-device from the latest `HealthDay` vs tuning baselines in `evidence`, plus anxiety ≥7 logged in last 2h.
- User's Settings breathing pace (existing) wins when they've set it explicitly (`hasCustomPace`).
- Recorder captures duration, pace and, when HealthKit HR samples exist for the session window, start/min/end HR.

- [ ] **Step 1: `TuningStore.selfCheck()`:** disabled → defaults; enabled with sample tuning → values from it; explicit Settings pace wins; offline → last cached tuning from UserDefaults.
- [ ] **Step 2–4:** fail → implement → sim + iPhone pass; run a guided session and confirm a `session_metrics` row.
- [ ] **Step 5: Commit.** Log progress.

### Task 6: NudgeScheduler (daily meditation reminder)

**Files:**
- Create: `Core/Services/NudgeScheduler.swift`, `Core/Models/NudgeOutcome.swift`
- Modify: `EbbApp.swift` (UNUserNotificationCenter delegate; reschedule on tuning load and foreground)

**Interfaces:**
- `final class NudgeScheduler { func reschedule(from: TuningStore) async; func record(_ outcome: NudgeOutcome, firedAt: Date) async }`. One repeating-daily request id `"meditation"`; skipped if inside a quiet window or toggle off. Actions: Open, Snooze 30 min. Opened = notification tap or app open within 1h of fire; no interaction for 3h = ignored (computed next launch).
- Copy (app UI, allowed): title "A few minutes for you", body "Your daily calm session is ready." Never mentions health data or medication.
- Permission asked from the Settings "Personalize Ebb" section or first time a reminder would be scheduled, not at launch.

- [ ] **Step 1: selfCheck:** reminder inside quiet window → not scheduled; timezone change → same local time, one pending request.
- [ ] **Step 2–4:** fail → implement → sim + iPhone pass (set reminder 2 min ahead via a DEBUG override and see it fire on the phone).
- [ ] **Step 5: Commit.** Log progress.

### Task 7: UI — Personalize settings, "Why this?", Connect Health, med windows

**Files:**
- Create: `Features/Settings/PersonalizeSection.swift`, `Features/Common/WhyThisButton.swift`, `Features/Common/WhyThisSheet.swift`, `Features/Profile/ConnectHealthCard.swift`
- Modify: `SettingsView.swift`, `ProfileView.swift`, `MedicationEditor.swift` (onset/wear-off fields, if chat Task 9 is done; else create them there), reset/session start screens (add `WhyThisButton`)

**Copy:** section footer "Ebb adjusts session length, breathing pace and reminder time to what works for you. Uses only your own data." Reset button "Reset to defaults" (`.confirmationDialog`). Empty evidence: "Using defaults until Ebb learns more." Connect card: "Connect Apple Health so sessions fit your sleep and heart rate."

- [ ] **Step 0:** `PersonalizeSection` lists the sleep targets with an editable wake time and bedtime (user-set wins, stored server-side as `userSet`). Copy follows wording-and-safety.md.
- [ ] **Step 1:** Implement (views read stores only). **Step 2:** sim + iPhone; check toggle off → defaults immediately, toggle on → last tuning back; Why-this shows evidence lines; Reduce Motion respected.
- [ ] **Step 3: Commit.** Log progress.

### Task 8: Docs and records

- [ ] Update `.claude/docs/roadmap.md`, `phase-2-personalization.md` (point to this spec/plan; mark the old "nightly on-device model" sketch superseded by server-side), `built-so-far.md`, `CLAUDE.md` ("Ebb never reminds anyone to take medication"). Commit. Ask the user before deploying functions or enabling cron on the hosted project.
