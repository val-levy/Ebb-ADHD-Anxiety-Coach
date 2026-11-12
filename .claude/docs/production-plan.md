# Production plan

Written 2026-11-11. Goal: take Ebb from the clickable, cloud-backed prototype to an App Store release for real users.
Master roadmap: [roadmap.md](roadmap.md). Rules: [wording-and-safety.md](wording-and-safety.md), AGENTS.md.

**Decisions (Val, 2026-11-11):** friends are in v1; stress detection is in v1; the app is free for now (business model
later); minimal anonymous analytics; Val will buy the paid Apple account and ship through TestFlight.
**Detection without a Watch app:** AGENTS.md says iPhone only. So detection reads the Apple Watch's heart rate through
HealthKit on the iPhone (background delivery, samples arrive every few minutes) plus iPhone motion. It is slower than the
spec's on-wrist detector (minutes, not about a minute), so it needs the Phase 0 test first and honest copy. If that
proves too slow, the Watch app question comes back to Val.

## Where we are
Done: all UI and the clay design, resets + guided sessions, brain dump, quick log, chat (OpenRouter Edge Function, memory,
rate limit), Reflect charts, profile/avatars, accounts (anonymous + email/password; Apple pending), remote Supabase,
RLS test, account deletion function.
Stand-ins ("Demo" code): friends, achievements rules on local data, patterns/insights copy, NextStepSuggester
(rule-based), settings that nothing reads yet.

## Phase A: Make the features real (no new accounts or money needed)
1. **Notifications that fire.** Verify planned nudges, cap, pause, snooze, false alarm end to end on a phone (docs
   disagree on whether they run). Request permission at a good moment, not on launch. Copy follows wording §4–5.
2. **Settings that do something.** Guard windows and "Stress signals" have no consumer without a Watch: hide or relabel
   them until they work (no dead controls in production). Medication schedule: log-only, never reminders (wording rule).
3. **Brain dump → next step.** Replace the rule-based `NextStepSuggester` with a server call (reuse the chat Edge
   Function guardrails, scope-locked prompt, no medical advice). Fallback to the rule-based step offline.
4. **Real Reflect.** Patterns and insights computed from real resets, doses, stressors and sessions; remove sample text.
   Empty states for a new user. No streaks, no guilt.
5. **Friends (v1).** `friendships` table + RLS (users see only accepted friends' shared fields), invite link / code,
   accept/decline/remove, block and report, no location, no raw health data shared. Decide what a friend sees (avatar,
   name, "resets that helped" count; never mood or logs). Breathe-together stays out of v1 unless cheap.
6. **Achievements.** Compute from synced data (not on-device only) so they survive reinstall; no streak-based rules.
7. **Offline and error states.** Resets and panic sessions must work with no network and sync later (queue writes).
   Every network call has a calm failure message; chat degrades gracefully.
8. **Data sync correctness.** Profile, avatar and settings (breath rate, schedules) stored per account, not only
   `@AppStorage`, so a new phone restores them.

## Phase B: Accounts, backend and security hardening
1. **Apple Developer Program** (paid): flip entitlements per AGENTS.md, enable Sign in with Apple, fill the provider
   secret in Supabase, test on device.
2. **Email confirmations ON** with custom SMTP (Resend/Postmark), custom reset templates (needs paid Supabase plan for
   templates; otherwise accept default). Test the `ebb://reset` link.
3. **Supabase plan and limits.** Move off the free tier before launch (backups, no pause-after-inactivity, rate limits).
   Enable point-in-time backups; document restore.
4. **RLS audit.** Re-run `rls.sh`, extend it to every table added since (`chat_style`, `user_memory`, `life_logs`,
   `brain_dumps`, `nudge_events`); add a CI step. Confirm Edge Functions verify the JWT and never trust client user ids.
5. **Secrets and abuse.** Keys only in Supabase secrets; rotate the OpenRouter key; per-user + global spend caps on
   OpenRouter; chat rate limit already 30/hr, 150/day; add a global kill switch.
6. **Panic ladder tamper-resistance.** Keychain counter exists; accept that reinstall resets it, or move the count
   server-side keyed to device attestation (App Attest) if abuse appears.
7. **Staging vs production.** A second Supabase project for TestFlight testing; migrations applied via CI, never by hand.

## Phase C: Safety, privacy and legal (blocks submission)
1. **Crisis path.** 988 reachable from every screen; chat detects crisis wording and surfaces 988 instead of
   advice; test with a scripted set of messages. Review by someone qualified.
2. **Wording audit.** Grep all UI strings, chat prompt, notifications, onboarding and App Store text against
   wording-and-safety.md (no condition claims, no medication advice, signals not conditions).
3. **Privacy.** Privacy policy + terms (hosted URL); App Store privacy label matching reality (chat text goes to
   OpenRouter with `data_collection: deny`, brain dumps and logs live in Supabase); in-app data export; account deletion
   verified end to end (Apple requirement); health-like data retention rules.
4. **Onboarding disclaimer:** "Ebb is a wellness tool, not medical advice. It doesn't diagnose or treat any condition."
5. **Lawyer review** of listing, terms, wording (FDA general-wellness guidance, App Store 1.4.1).
6. **Age rating / audience.** 17+ or 13+ decision; no child-directed claims. Clay/animal style must not read as kids-only.

## Phase D: Quality
1. **Tests.** Unit tests for stores and models (ResetStore, CalmStore, PanicGate, ReflectModule, insights); the existing
   `selfCheck()` asserts become real XCTests. UI smoke tests for panic → session → rating.
2. **CI.** Build + tests + `rls.sh` on every PR (workflow exists, extend it).
3. **Device matrix.** Test on small and large iPhones, iOS minimum version, light/dark, Dynamic Type max, VoiceOver
   walk-through of panic, Reduce Motion, low power mode, poor network.
4. **Performance.** Cold-start time, scroll hitching on scene screens (profile with Instruments), memory in sessions,
   battery in a 10-minute session.
5. **Crash and error reporting.** Add Apple's MetricKit or a privacy-light crash reporter; no third-party analytics that
   conflict with the privacy label. Decide product analytics (see Open decisions).
6. **Accessibility pass.** Labels on custom clay icons (kind.label is empty for most), tab bar animal icon label, tip
   coach readable by VoiceOver, contrast in both modes.

## Phase E: Release
1. **App assets:** final icon, screenshots (light + dark), preview video, listing copy (wellness wording), keywords,
   support URL, marketing URL.
2. **Business model.** Free for v1 (decided); StoreKit later. Keep chat capped.
3. **TestFlight beta:** 10–20 people from ADHD communities, 3 weeks, in-app feedback link. Gate: helped rate and
   no-crash rate (targets in business-launch.md).
4. **App Review prep:** demo account, notes on chat model use and crisis handling, 1.4.1 and 5.1.1 compliance.
5. **Launch ops:** support email, status/incident plan for Supabase or OpenRouter outages, release checklist, versioning,
   staged rollout.

## Phase F: Stress detection on iPhone (v1, runs alongside A–D)
1. **Phase 0 test first (cheapest, run 14 days):** log on-demand "I'm spiraling" taps next to HealthKit heart rate and
   iPhone motion; check whether taps line up with a rise while still at least half the time (roadmap gate).
2. **HealthKit permission + background delivery:** `HKObserverQuery` + background delivery for heart rate; read resting
   baseline; request permission with a plain-language reason at a good moment.
3. **Rule detector:** heart rate well above rolling baseline while motion is low, sustained across available samples;
   conservative start, cap 3 a day, quiet hours, pause/snooze/false-alarm already built.
4. **Delivery:** local notification (iPhone cannot haptic-tap a Watch app that doesn't exist; the Watch mirrors iPhone
   notifications). Copy describes the signal, never a condition (wording §4).
5. **Feedback loop:** helped / didn't / false alarm stored per nudge; false alarms raise the threshold.
6. **Honest limits in-app and in App Review notes:** samples can lag several minutes; works best with a worn Watch;
   without one, detection is off and everything else works.
7. **Battery and privacy:** no continuous polling; health data stays on device (only the nudge label syncs).

## After launch (not on this plan)
Personal model (Phase 2 docs), Watch app with on-wrist detection, Bluetooth sensors, therapist export, Android.

## Analytics (decided: minimal, anonymous)
Count-only events, no text, no health values, no user id (random per-install id at most, resettable). Candidates:
app opened, reset started/completed, panic session started/completed, rating given (helped / not), nudge response,
chat session started (not content), sign-up completed, crash. Use Apple's own App Analytics + MetricKit, or a
self-hosted counter table; no ad or tracking SDKs. Must match the privacy label.

## Open decisions for Val
1. What exactly a friend can see (suggested above).
2. Whether to ask for TestFlight testers' feedback in-app or by email.

## Pricing
Free for now. Chat has ongoing cost: keep the rate limit and a global spend cap until the business model is set.

## Suggested order
F1 (start the 14-day test early) + A1–A4, A7, A8 (what users touch daily) → C1–C4 in parallel → B1–B5 once the paid account exists → D → E.
Cheapest high-risk items first: notifications on device (A1), crisis handling (C1), RLS audit (B4), privacy/legal (C3, C5),
since they can reshape other work.
