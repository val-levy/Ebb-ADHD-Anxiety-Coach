# Production plan

Written 2026-11-11. Goal: take Ebb from the clickable, cloud-backed prototype to an App Store release for real users.
Master roadmap: [roadmap.md](roadmap.md). Rules: [wording-and-safety.md](wording-and-safety.md), AGENTS.md.

**Scope note.** AGENTS.md says iPhone only, no Watch app. So the spec's Watch detection is *not* on this plan; the
launch product is on-demand resets, guided calm, brain dump, chat, logging, Reflect insights and friends.
Passive detection is listed under "After launch" and needs a decision from Val (see Open decisions).

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
5. **Friends.** Decide scope (see Open decisions). If kept: `friendships` table + RLS, invite link, breathe-together is
   cut for v1. If not: remove the card and its tip.
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
2. **Business model.** Decide free vs paid. If paid: StoreKit 2, free tier = panic + resets, unlock = chat/personalization
   (chat costs real money per user, so it likely needs to be paid or capped). Restore purchases, receipt validation.
3. **TestFlight beta:** 10–20 people from ADHD communities, 3 weeks, in-app feedback link. Gate: helped rate and
   no-crash rate (targets in business-launch.md).
4. **App Review prep:** demo account, notes on chat model use and crisis handling, 1.4.1 and 5.1.1 compliance.
5. **Launch ops:** support email, status/incident plan for Supabase or OpenRouter outages, release checklist, versioning,
   staged rollout.

## After launch (not on this plan)
Passive stress detection (needs Watch or HealthKit background and a Phase 0 test), personal model (Phase 2 docs),
Bluetooth sensors, therapist export, Android.

## Open decisions for Val
1. **Friends in v1 or cut?** Biggest unbuilt feature that needs backend work.
2. **Detection without a Watch app:** drop it for launch (recommended), or revisit Watch later?
3. **Pricing:** free + one-time unlock, or subscription (chat has ongoing cost)?
4. **Analytics:** none (matches privacy promise) or minimal anonymous events?
5. **Paid Apple account timing:** it gates Apple sign-in, TestFlight and everything in Phase E.

## Suggested order
A1–A4, A7, A8 (what users touch daily) → C1–C4 in parallel → B1–B5 once the paid account exists → D → E.
Cheapest high-risk items first: notifications on device (A1), crisis handling (C1), RLS audit (B4), privacy/legal (C3, C5),
since they can reshape other work.
