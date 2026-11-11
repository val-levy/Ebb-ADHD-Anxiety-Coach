# Ebb personal model — design

Date: 2026-11-10 · Status: draft for approval · Depends on: accounts; shares data with the chat companion
(`chat-companion-design.md` §5).

---

## 1. Why

Every person's body runs differently. The user's examples:

> "it would know exactly how long you should breathe for based on your average heart rates, when you should do
> meditation based on how you slept … it should also know things about you and your medication and understand
> and adjust based on the timing of your medication. it will get better the more info you give it like your
> nutrition, timing of nutrition, timing of medication, sleep health, stress health, things to do during the day,
> hrv, blood oxygen, breathing rate, heart rate, etc."

The personal model makes the **app itself** fit the person: how long resets last, how fast the breathing pace is,
when the daily meditation reminder fires, when nudges are allowed, and which reset is offered first.

## 2. The line between this and the chat

The personal model changes **app behaviour and normal app UI**, which the user said may suggest things
("bringing people into the app to do their daily meditation" is fine). It never writes chat text and never
talks about medication as an instruction. Concretely:

- ✅ "Time for your 2-minute reset" reminder at 3:40pm because that's when the user's afternoon dip shows up.
- ✅ Breathing session defaults to 4 minutes at 5.5 breaths/min for this user.
- ❌ Any reminder about taking medication. Ebb does not remind people to take meds (that's medical territory;
  the user has phone reminders for that). The model only *uses* dose times as context.
- ❌ Any text that explains a health reason ("your HRV is low, so…"). Personalized UI just *is* personalized;
  the "Why this time?" sheet (§8) shows facts only, phrased as patterns.

## 3. Goals

1. Personalize five things, each with a safe default that's used until there's enough data:

   | Target | Default today | Personalized from |
   |---|---|---|
   | **Reset length** (quick + guided) | fixed per reset | how long until resets/sessions "helped"; resting HR & HRV baseline |
   | **Breathing pace** (breaths/min, inhale:exhale) | user's Settings pace | resting respiratory rate, HRV response during sessions (Watch, later), helped-rate per pace |
   | **Daily meditation reminder time** | none / user-set | sleep end time, sleep quality, when sessions were done and helped, med timing |
   | **Nudge windows** (when detection nudges may fire — detection itself is Phase 1's Watch work) | always on, capped | anxiety/panic times of day, med timing, sleep debt, snoozes/dismissals |
   | **First reset offered** | fixed order | helped-rate per kind × time of day × state |

2. Learn **per user**, from their own data only. No pooled model across users in v1.
3. Get better as more data types are given; work with any subset (only app usage, or + Health, or + meds, etc.).
4. Explainable: every personalized value has stored evidence.
5. Reversible: Settings → "Personalize Ebb" toggle (on by default after enough data), plus "Reset to defaults".

## 4. Non-goals and anti-goals

**Non-goals:** neural networks or LLMs in the loop; cross-user learning; on-device training (revisit when
Core ML personalization is worth it); detection of panic from sensors (Phase 1 Watch project); any change to what
the chat AI says.

**Anti-goals (fails even if it works when):**
- A value swings wildly day to day (a 2-minute reset tomorrow, 9 minutes the day after). Changes are bounded (§7).
- It personalizes from 3 data points. Every target has a minimum-data rule.
- It schedules something during sleep or during a time the user marked busy.
- It's a black box. If Ebb can't say "why", it doesn't change the value.
- It does anything the user can't turn off.

## 5. Data in

All data in Supabase under the user's account (same tables as the chat spec §5.3), so one data home.

### 5.1 Apple Health (HealthKit) ingestion — new on iOS

- Capability: HealthKit (read-only). Requested on first open of a "Connect Apple Health" card in Profile (normal
  UI), never at launch. Usage string: "Ebb reads sleep, heart and breathing data to fit sessions and reminders to
  you. It never writes to Health."
- Types read: `sleepAnalysis` (category), `restingHeartRate`, `heartRate`, `heartRateVariabilitySDNN`,
  `respiratoryRate`, `oxygenSaturation`, `stepCount`, `activeEnergyBurned`, `mindfulSession`; optional nutrition:
  `dietaryEnergyConsumed`, `dietaryCaffeine` (only if the user logs nutrition in another app).
- `HealthSyncService` (Core/Services): on app foreground and via `HKObserverQuery` + background delivery
  (hourly) aggregates **per local day** into the `health_daily` row (upsert on `(user_id, day)`), last 30 days
  on first sync, then incremental with `HKAnchoredObjectQuery` anchors stored in UserDefaults.
- Raw samples are **not** uploaded. Only daily aggregates + sleep start/end. Heart rate during a session (for
  the response measure in §6.2) is uploaded as a 3-number summary per session: HR at start, HR min, HR at end.
- Aggregation rules: sleep = sum of `asleep*` stages in the night ending on `day` (window 18:00 previous day →
  14:00 day); `sleep_efficiency` = asleep / inBed; resting HR / HRV / respiratory rate / SpO₂ = mean of that day's
  samples (HRV: overnight samples only, 00:00–08:00, when present).

### 5.2 From the chat and app

`log_entries` (meds taken/missed, meals, caffeine, alcohol, sleep reports, mood, anxiety, focus, energy, stressors,
activities, plans), `medications` (schedule), `resets` (kind, helped, time), `calm_sessions` (program, before/after
intensity), new: `nudge_events` (fired_at, outcome: opened / snoozed / dismissed / ignored), new:
`session_metrics` (session id, duration_s, pace_bpm, hr_start, hr_min, hr_end).

Busy times: `plan` log entries with a time + an optional calendar read (EventKit, read-only, opt-in, later — not v1).

## 6. The model

**Where it runs: server-side, nightly.** A Supabase cron triggers Edge Function `personalize` once per user per
night (03:30 user-local). It reads the user's data under the service role, computes parameters, writes one row to
`user_tuning`. The app reads `user_tuning` on launch and on foreground (cached in UserDefaults for offline).
Why server: the data already lives there, it runs while the phone sleeps, and it's one TypeScript code path.
The math is small enough that moving it on-device later is a port, not a rewrite.

**What kind of model:** per-user statistics and bandits — not deep learning. It's the right tool for one person's
few hundred data points and it's explainable. Four estimators:

### 6.1 Baselines (rolling, robust)

For each metric (resting HR, HRV, respiratory rate, SpO₂, sleep minutes, sleep end): 28-day **median** and
**MAD** (median absolute deviation), plus a 7-day EWMA (α = 0.25). "Today is unusual" = |today − median| > 1.5 × MAD.
Minimum: 10 days of the metric.

**Medication-aware baselines:** for users with scheduled meds, every log/health point gets a `med_phase` label from
the dose times of that day: `pre` (before the first dose), `onset` (0–1h after), `active` (1–6h), `wearing_off`
(6–9h), `off` (>9h or missed day). Windows are defaults the user can edit per medication in Profile → Medications
("usually kicks in after… / wears off around…") — user-entered, no drug database. Baselines for anxiety, focus,
panic/reset rate are computed **per phase** when each phase has ≥ 8 points; otherwise pooled.

### 6.2 Reset length and breathing pace — Thompson sampling over a small grid

- Arms for **length**: {1, 2, 3, 4, 5, 7} minutes for guided; quick resets {60, 90, 120} s.
- Arms for **pace**: {4.5, 5, 5.5, 6, 6.5} breaths/min; inhale:exhale fixed at 4:6 ratio scaled.
- Reward per session (0–1): `helped` (resets) or `(before−after)/max(before,1)` clamped (calm sessions); when
  `session_metrics` HR exists, add 0.3 × normalized HR drop (`(hr_start−hr_min)/hr_start / 0.15`, clamped 0–1)
  and rescale to 0–1.
- Beta(α,β) per arm, prior Beta(2,2) centered on the current default; nightly update from new sessions; decay old
  evidence by 0.97/day so it follows change. The app picks the arm with the highest posterior **mean** for the
  default (exploitation), and 1 session in 5 the app samples (exploration) — but **never more than one grid step
  from the current default**.
- Context split: arms are tracked separately for `state ∈ {calm, elevated}` where elevated = today's resting HR
  > median + 1.5·MAD or HRV < median − 1.5·MAD or anxiety logged ≥ 7 in the last 2h. Elevated → default skews to
  the longer/slower arm with the best posterior.
- Minimum: 8 rated sessions before leaving the default.

### 6.3 Meditation reminder time — scored candidate slots

- Candidates: 15-minute slots from wake+30min to sleep_start−60min (from medians), excluding busy `plan`s.
- Score per slot = 0.4 × P(session done within 1h of a reminder at this slot) (Beta per slot, from `nudge_events`)
  + 0.3 × helped-rate of sessions started in this hour + 0.2 × "dip fit" (how often anxiety/low focus/resets
  cluster in the 2h after this slot, from logs, normalized) + 0.1 × med-phase fit (prefers `wearing_off` and `off`
  phases for ADHD-med users, because that's where dips cluster, *if* their own data shows it — the weight is 0
  until the per-phase anxiety baseline exists).
- Sleep-aware: when last night's sleep < median − 1.5·MAD, the chosen slot moves earlier by up to 2h (to the
  best-scoring slot in the morning window) and the default session is the longer arm. This is the user's
  "when you should do meditation based on how you slept".
- Bounded: moves at most 45 min per day; user-set fixed time always wins.

### 6.4 Nudge windows and reset ordering

- **Quiet windows:** sleep (median sleep_start−30min → median sleep_end+30min), busy plans, and any hour with a
  dismiss rate > 70% over ≥ 6 nudges.
- **Cap:** the Settings cap stays a hard ceiling; the model can only lower it (e.g. after 3 dismissals in a row,
  half-cap for 48h).
- **Reset ordering:** helped-rate per reset kind with Beta(1,1), per (time-of-day bucket × state); sort by
  posterior mean, keep the user's favourite (if set) first.

## 7. Safety rails (all targets)

- Hard bounds: lengths 1–10 min, pace 4–7 bpm, reminders 07:00–22:00 unless the user sets otherwise.
- Max change per night per target (one grid step / 45 min).
- If data for a target goes stale (> 14 days without new points) revert to default over 7 days.
- Anything flagged `elevated` never *shortens* a session.
- Kill switch: Settings toggle; plus a server flag `personalization_enabled` in `user_tuning` to disable remotely.

## 8. App (iOS)

- `TuningStore` reads `user_tuning` (+ UserDefaults cache) and exposes `resetLength(for:)`, `breathingPace(state:)`,
  `meditationReminder`, `quietWindows`, `resetOrder`. Existing stores ask it instead of constants.
- `NudgeScheduler` (local notifications) schedules the daily meditation reminder from `TuningStore`, and records
  outcomes into `nudge_events` (via notification actions + app-open attribution within 1h).
- **"Why this?"** small info button on personalized items opens a sheet listing the evidence facts, e.g.
  "Your guided sessions of 4 minutes were rated as helping 9 of 11 times; 2-minute ones 3 of 7." Patterns only.
- Settings → **Personalize Ebb** section: toggle, "Reset to defaults", list of what's personalized with each
  current value, Apple Health connection status.
- Profile → Medications (shared with chat spec): adds optional "kicks in after" / "wears off around" per med.

## 9. Data out

```
user_tuning (one row per user)
  user_id pk, computed_at, version int,
  personalization_enabled bool default true,
  reset_length jsonb   -- { "guided": {"calm": 240, "elevated": 300}, "quick": {...} } seconds
  breathing   jsonb    -- { "calm": 5.5, "elevated": 5.0 } bpm
  meditation_reminder time null, reminder_reason jsonb,
  quiet_windows jsonb  -- [{start:"23:00", end:"07:30"}...]
  reset_order jsonb    -- { "morning": ["sigh","breathe",...], ... }
  evidence jsonb       -- per target: the numbers shown in "Why this?"
  arms jsonb           -- bandit posteriors (α,β per arm per context), for the next night

nudge_events, session_metrics  (new, own-row RLS)
```

## 10. Decided by the user vs. my calls

**User decided:** a per-user model that personalizes breathing length from heart rate, meditation timing from
sleep, adjusts around medication timing, uses the full metric list, improves with more data; normal app UI may
suggest (reminders), AI may not.

**My calls (check these):**
1. Runs server-side nightly in an Edge Function (user said local vs remote was open; server keeps one data home
   with the chat).
2. Statistics + Thompson-sampling bandits, not neural nets.
3. Ebb never reminds anyone to take medication; med times are context only.
4. Med effect windows are user-entered defaults, no drug database.
5. Only daily aggregates leave the phone, not raw HealthKit samples.
6. Exploration limited to one grid step from the default.
7. Calendar reading postponed.

## 11. Left to the builder

Exact score weights after first real data (starting values above), UI placement details, cron batching by timezone.
