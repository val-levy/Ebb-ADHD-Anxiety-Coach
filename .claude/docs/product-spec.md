# Ebb: a calm companion for busy minds

> **Wording (2026-11-10):** all copy follows [wording-and-safety.md](wording-and-safety.md). Ebb is built with
> ADHD brains in mind but never claims to detect, treat or manage a condition.

Nov 4, 2026 · @Val

## Executive summary

Ebb is an Apple Watch and iPhone companion that notices rising stress from your body's signals and offers a 60-second reset on your wrist, within about a minute. Everything runs on the device: no server, no account, no data leaves the phone.

- **For:** adults with busy, easily overloaded minds (built with ADHD in mind) who already wear an Apple Watch and forget to open calming apps when it matters.
- **How:** heart rate that rises while the body is still is treated as a stress signal. A small personal model decides whether to nudge, and the user's one-tap feedback retrains it nightly.
- **Why local:** moment-to-moment mental-health data is the most sensitive data a person has, and a nudge only helps in the moment.
- **Biggest risk:** Apple Watch does not give third-party apps continuous, fast heart rate all day. Ebb works around this with guard windows, an on-demand tap, and an optional Bluetooth sensor (see Setbacks).
- **Moat:** a model that learns each user's own stress signature and best reset, which never leaves their phone.

## Problem and target user

People with ADHD and anxiety often know what calms them, but they don't remember to use it until the spiral is well underway. Meditation and breathing apps wait to be opened, which is exactly what an overloaded ADHD brain doesn't do.

**Primary user:** an adult (roughly 20–45) with diagnosed or self-identified ADHD plus anxiety, who wears an Apple Watch daily.

- Has tried apps like Calm or Headspace and dropped them within weeks.
- Notices stress late: the racing heart, tight chest, or snapping at someone comes before the thought "I'm stressed."
- Has hyperfocus crashes: hours of stillness, skipped meals, then a sudden drop in mood.
- Is wary of mental-health apps that sell or share data.

**Secondary users:** therapists who assign between-session homework, and ADHD coaches who want clients to notice patterns.

**The job to be done:** "Catch me before I spiral, give me something I can do in under two minutes without thinking, and help me learn what sets me off."

## Why on-device

Ebb only works if it runs locally. Each reason below would sink a cloud version on its own.

| Advantage | Why it matters for Ebb |
| --- | --- |
| Privacy | Users won't trust an app with live stress and mental-health signals unless "nothing leaves your phone" is literally true. |
| Latency | A nudge after the spiral is useless. Detection and the haptic must happen on the Watch, within about a minute. |
| Offline resilience | Stress happens on the bus, in the subway, at the gym. The Watch may not be near the phone or online. |
| Zero inference cost | The model checks the user many times a day. On-device inference costs nothing, which allows a one-time price. |
| Personalization | Each user's model trains on their own data overnight. That learned profile is the product, and competitors can't copy it. |

## Core loop

Ebb runs a four-step loop: the Watch senses and decides within about a minute, offers a reset, and the iPhone learns from your answer overnight.

&#91;embedded content: core loop · sense, decide, offer, learn\]

The on-demand tap skips Sense and Decide and goes straight to Offer, so it works from day one.

## Data sources and real-world latency

Near-instant data is possible on Apple Watch only while the app runs a session on the Watch itself. Everything else is too slow for in-the-moment detection and serves baselines and trends.

| Source | Access path | Latency | Used for | Catch |
| --- | --- | --- | --- | --- |
| Heart rate during a session | `HKWorkoutSession` + live workout builder | \~1–5 s | Live arousal detection | Battery drain; App Store framing risk |
| Accelerometer / gyroscope | Core Motion | Real time, up to \~100 Hz | Stillness vs movement, fidgeting | App must be active or in a session |
| Historical accelerometer | `CMSensorRecorder` | Minutes to hours later | Hyperfocus / stillness patterns, training data | Not live |
| Background heart rate | HealthKit | Every few minutes | Daily baselines | Too slow to catch a spike |
| HRV (SDNN) | HealthKit | Periodic, mostly at rest and asleep | Daily readiness, threshold tuning | No live beat-to-beat HRV for third parties |
| Sleep, wrist temperature, respiratory rate | HealthKit | Overnight summaries | Lower threshold after poor sleep | Summaries only |
| Bluetooth HR strap or armband (e.g. Polar Verity Sense) | Core Bluetooth, standard HR profile | \~1 s, with beat-to-beat intervals | Optional power-user mode, true live HRV | Extra hardware to wear |
| Watch → iPhone HealthKit sync | HealthKit | Seconds to many minutes | Nightly retraining only | Unpredictable; never use for live work |

**Design consequence:** detection runs on the Watch. The iPhone handles nightly retraining, history, and anything that needs a language model.

## Stress and state detection

The main signal is heart rate that rises while the body stays still. If heart rate climbs well above your baseline and the accelerometer says you're sitting, that's likely stress rather than exercise.

**Detection window:** a stress response builds over 30–90 seconds, and it takes about that long to rule out standing up or laughing. Ebb judges rolling 60-second windows, so nudges land within about a minute. Second-by-second reaction would mostly produce false alarms.

**Signals Ebb looks for** (described as signals, never as conditions; see [wording-and-safety.md](wording-and-safety.md) §4):

| Signal | Pattern | What Ebb offers |
| --- | --- | --- |
| Stress signal | HR well above rolling resting baseline, low motion, sustained 60+ s | A breathing reset |
| Restless signal | Repetitive small wrist movements, HR mildly elevated | A grounding or body reset |
| Long stretch still | Near-zero movement for 2+ hours, no breaks | A body break |
| Low-threshold day | Short sleep or low overnight HRV | Nudges a little earlier today |

**Three ways a reset gets triggered:**

1. **Guard windows:** the user picks high-risk hours (commute, work blocks, evenings). Ebb runs a session then, with HR every few seconds plus motion.
2. **On-demand tap:** a Watch complication meaning "I'm spiraling, help." Always instant, and the best labeled training data.
3. **Opportunistic:** background HR samples outside guard windows. Slower, used for trends and gentle check-ins.

**Personalization:** a starting rule (for example, HR 20+ bpm above resting while still for 60 s) begins conservative. Each nudge's feedback (helped / didn't / false alarm) and each on-demand tap become labels. A small per-user model (logistic regression or gradient boosting) retrains nightly on the iPhone and sends updated thresholds back to the Watch.

## Interventions

Every reset is one tap to start and takes under 90 seconds. A stress signal and feeling overloaded need different help, so Ebb picks from two families based on the signal.

| Reset | For | Length | Where it runs | What happens |
| --- | --- | --- | --- | --- |
| Haptic paced breathing | Stress signal | 60 s | Watch | Taps guide a long exhale. Eyes-free, works in meetings. |
| Physiological sigh | Stress signal | 30 s | Watch | Two inhales, one long exhale, repeated 3 times. |
| Grounding prompt | Stress signal | 45 s | Watch | One screen: "Name 3 things you can see." |
| Body break | Long stretch still | 90 s | Watch | "Stand up, drink water." Interrupts hyperfocus before the crash. |
| One next thing | Overload | \~60 s | iPhone | Say what's overwhelming; an on-device language model returns one 5-minute starting step. |
| Brain dump | Overload | \~60 s | iPhone or Watch dictation | Dictate everything spinning; Ebb files it so you don't have to hold it. |

After each reset, one tap: **helped**, **didn't help**, or **false alarm**. Over time Ebb learns which reset works for which state, time of day, and place, and offers that one first.

## Design principles

For this audience, how Ebb speaks and how often it interrupts matter more than how accurate the model is.

1. **Describe the signal, offer an action.** Alerts name the signal, never a condition, and always open a reset: "Your heart rate's up while you're sitting still. Breather?" Never "panic attack detected" or a raw number. No warning-only alerts. Settings calls it "Stress signals". Full rules: [wording-and-safety.md](wording-and-safety.md) §4.
2. **False alarms cost more than misses.** ADHD users mute apps that cry wolf within days. Start conservative and cap nudges at 3 a day by default.
3. **One tap, under 90 seconds, on the wrist.** If a reset needs the phone or reading, it won't get used in the moment.
4. **Fight novelty decay.** ADHD brains tune out repeated stimuli. Rotate haptic patterns and wording automatically.
5. **No streaks, no guilt.** Show "resets that helped this week," never a broken streak.
6. **The user is always in control.** Snooze for an hour, pause for the day, or turn off guard windows with one tap.
7. **A safety valve, not a clinic.** "Ebb is a wellness tool, not medical advice. It doesn't diagnose or treat any condition." If the user signals a crisis, it surfaces a trusted contact or a crisis line such as 988 in the US.

## Technical architecture

Everything time-critical runs on the Watch; everything heavy runs on the iPhone overnight. There is no server.

&#91;embedded content: architecture · Watch and iPhone, no server\]

The Watch and iPhone talk through WatchConnectivity, with events queued on the Watch. An optional Bluetooth armband (v2) would feed live HR and HRV straight to the Watch detector. Core tools: Create ML for the motion classifier, Core ML for on-device inference, HealthKit and Core Motion for data.

## Setbacks and workarounds

The hardest setback is platform access: Apple Watch won't give Ebb fast heart rate all day. Every other risk has a known workaround; this one shapes the whole product.

### Technical

| Setback | Why it hurts | Workaround |
| --- | --- | --- |
| No continuous fast HR outside a workout session | Background samples arrive every few minutes, too slow to catch a spike | Guard windows (session only during high-risk hours), the on-demand tap, and an optional Bluetooth armband for all-day live data |
| No live beat-to-beat HRV on Apple Watch | The best stress marker in research is out of reach | Use HR vs motion live; use HealthKit HRV only for daily baselines. Power users can pair a Polar Verity Sense or H10 for real HRV |
| Battery drain from long sessions | Users uninstall apps that kill their Watch by evening | Cap guard windows (e.g. 3 hours a day to start), run detection only on Watch, show the battery cost in settings, auto-stop below 30% battery |
| Watch app gets suspended | watchOS aggressively stops background apps | Do all live work inside the session; keep the Watch model tiny; never depend on the iPhone during detection |
| Watch → iPhone sync is slow and unreliable | Labels and logs may arrive late | Queue events on the Watch with WatchConnectivity; retrain only nightly while charging |
| Motion confounds | Caffeine, heat, illness, laughing, sex, and climbing stairs all raise HR | 60-second windows, a motion gate, time-of-day context, and user feedback to learn each person's confounds |
| Medication effects | ADHD stimulants raise resting HR and shift baselines | Let users log dose times; learn separate baselines for on- and off-medication hours |
| Cold start | The personal model is weak for the first 1–2 weeks | Launch with conservative rules plus the on-demand tap, so value comes before the model learns |
| Language model availability | On-device language models only run on recent iPhones | Make "One next thing" an optional extra; core resets need no language model |

### Product and behavioral

| Setback | Why it hurts | Workaround |
| --- | --- | --- |
| Alert anxiety | A stress alert can itself cause stress | Invitation wording, no numbers in the moment, gentle haptics, and an easy snooze |
| False alarms erode trust | Muted apps never come back | Nudge cap, high starting threshold, "false alarm" button that visibly lowers future alerts |
| Novelty decay | ADHD users stop noticing the same buzz | Rotate haptics and wording; refresh reset options monthly |
| Forgetting to set up guard windows | The fast-detection path never runs | Suggest windows automatically from calendar patterns and past on-demand taps |
| Feedback fatigue | Users stop rating resets, so learning stops | One tap only; skip the question when Ebb is confident; never require it |
| Weak results in the first week | Users judge apps fast | Lead with the on-demand reset, which works on day one |

### Platform, legal, and business

| Setback | Why it hurts | Workaround |
| --- | --- | --- |
| App Store review of workout sessions | Running a "workout" when the user isn't exercising may be rejected | Use a session type that fits (mindfulness or "other"), explain the use plainly in review notes, and have a fallback build without long sessions |
| Medical device regulation | Claiming to detect or treat anxiety or panic can make the app a regulated medical device | Follow [wording-and-safety.md](wording-and-safety.md) (FDA General Wellness guidance, App Store 1.4.1) and have a lawyer review it and the listing before launch |
| Health data rules | Even local apps fall under App Store health-data rules and some state privacy laws | No servers, no analytics on health data, a clear privacy label, and opt-in iCloud backup only |
| Crisis situations | Some users will be in real danger | Clear crisis path in the app, honest copy that Ebb isn't emergency care |
| Small reachable market | Requires Apple Watch plus ADHD/anxiety | Start there for focus; later add Bluetooth bands and Wear OS once the core works |
| Competition from Apple | Apple could add similar features to watchOS | Go deeper than Apple will: ADHD-specific resets, personal models, therapist exports |

### Validation risk

| Setback | Why it hurts | Workaround |
| --- | --- | --- |
| Your stress may not show clearly in HR | The whole detection idea fails | Run a 2-week personal prototype first (see Validation plan) before building the full app |
| Your data alone isn't representative | Works for you, fails for others | Recruit 10–20 beta users from ADHD communities before launch |

## MVP scope and roadmap

Build in four phases, each gated by evidence. A solo iOS developer can reach a TestFlight beta in roughly 10–12 weeks.

1. **Phase 0 — Personal prototype (weeks 1–2).** A bare Watch app that runs a session, streams HR and motion to a local log, and has one "I'm stressed" button. You wear it for 2 weeks.
   - Gate: your stress taps line up with visible HR-while-still rises at least half the time.
2. **Phase 1 — MVP (weeks 3–8).**
   - On-demand complication with haptic breathing, physiological sigh, and grounding
   - Guard windows with rule-based HR-vs-motion detection on the Watch
   - One-tap feedback after every nudge; nudge cap and snooze
   - Weekly private insight on iPhone ("Spikes cluster Tuesday afternoons; breathing helped 4 of 5 times")
   - Gate: 10 beta users keep it on for 3 weeks, with false alarms under 1 a day.
3. **Phase 2 — Personalization (weeks 9–12).**
   - Nightly per-user model retrained on the iPhone; updated thresholds sent to the Watch
   - Medication dose logging and separate baselines
   - Body-break nudge for hyperfocus
   - Gate: personalized nudges are rated "helped" more often than rule-based ones.
4. **Phase 3 — v2 (after launch).**
   - Intervention picker that learns which reset works when (a contextual bandit)
   - "One next thing" and brain dump with an on-device language model
   - Optional Bluetooth armband mode for live HRV
   - Therapist-ready PDF export of patterns

**Out of scope for MVP:** language-model features, Bluetooth sensors, Android, iCloud backup, therapist features.

## Validation plan and success metrics

The first question is whether your own stress shows up in your Watch data. Answer it in two weeks before writing the full app.

**Personal prototype protocol (Phase 0):**

- [ ] Build the bare session-logging Watch app
- [ ] Wear it during 2–3 guard windows a day for 14 days
- [ ] Tap "I'm stressed" whenever you notice stress; note caffeine and medication times
- [ ] Export the log and plot HR, motion, and taps on one timeline
- [ ] Check: how many taps had an HR-while-still rise in the 2 minutes before? How many rises had no tap?

**Success metrics after launch:**

| Metric | Target | Why it matters |
| --- | --- | --- |
| Nudges rated "helped" | 50%+ | The core value |
| False alarms per day | Under 1 | Above this, users mute the app |
| Users still active after 4 weeks | 40%+ | Beats typical wellness-app retention |
| On-demand taps per active user per week | 3+ | Shows the user reaches for Ebb when stressed |
| Battery used per guard-window hour | Under 5% of Watch battery | Above this, users stop using guard windows |

These targets are starting guesses to test, not benchmarks.

## Business model and positioning

Because inference is free, Ebb can sell a one-time lifetime license, which stands out among subscription-heavy wellness apps.

- **Free tier:** on-demand resets and the weekly insight.
- **Lifetime unlock (around $25–40):** guard windows, personalization, medication baselines.
- **Later add-on:** therapist export and Bluetooth sensor mode.

**Positioning:** "The calm button that presses itself. Private by design: nothing leaves your phone."

**Channels:** ADHD communities on Reddit and Discord, ADHD coaches and therapists, and privacy-focused tech press. The privacy story and the ADHD-specific design are the two things to lead with.

**How Ebb differs:** meditation apps wait to be opened; general wearables report stress scores but don't intervene in the moment or adapt to ADHD; Ebb does both and learns per person.

## Open questions and next steps

**Open questions:**

- Which session type will App Store review accept for long guard windows?
- How much battery does a 1-hour session actually cost on current Watch models?
- Does your stress show up as HR-while-still, or more as fidgeting?
- How strongly do stimulant medications shift baselines through the day?
- Which wording makes a nudge feel supportive rather than alarming? Test 3–4 variants with beta users.

**Next steps:**

- [ ] Build the Phase 0 personal prototype
- [ ] Wear it for 14 days and review the timeline
- [ ] Measure battery cost per session hour
- [ ] Read Apple's HealthKit, workout session, and health-data App Review guidelines
- [ ] Recruit 10–20 beta users from ADHD communities
- [ ] Get a short regulatory read on wellness vs medical claims
