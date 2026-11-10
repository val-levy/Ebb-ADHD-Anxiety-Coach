# Phase 0: Personal prototype

Status: **not started** · Source: product-spec.md, "MVP scope" and "Validation plan" · Master: [roadmap.md](roadmap.md)

## Why
The whole product rests on one bet: your stress shows up as heart rate rising while your body is still.
This phase tests that bet in two weeks, before more Watch work is built on it. If it fails, detection is redesigned
(e.g. fidgeting, Bluetooth strap) instead of building Phase 1 on sand.

## What to build
- A bare watchOS target in the existing XcodeGen project (`apps/ios/project.yml`), no UI polish.
- Runs an `HKWorkoutSession` (mindfulness/"other" type) during a manual or scheduled window.
- Streams heart rate (live workout builder) and Core Motion (accelerometer magnitude) to a local log file.
- One big "I'm stressed" button that timestamps a tap; a second small button notes caffeine/medication.
- Export: share the log as CSV to the iPhone (Files or AirDrop). No Supabase, no sync.

## Protocol
- [ ] Wear it during 2–3 windows a day for 14 days.
- [ ] Tap "I'm stressed" whenever you notice stress; note caffeine and medication.
- [ ] Plot heart rate, motion and taps on one timeline (a small script in `.claude/resources/tools/`).
- [ ] Count: taps with a heart-rate-while-still rise in the 2 minutes before; rises with no tap.
- [ ] Measure battery cost per session hour.

## Gate
Stress taps line up with a visible heart-rate-while-still rise **at least half the time**.

## Open questions it answers
- Does your stress show as heart rate, or more as fidgeting?
- Battery cost of a 1-hour session on your Watch model.
- How much stimulant medication shifts your resting heart rate.

## Needs
- An Apple Watch paired to the phone. HealthKit and workout sessions work on the free developer team for personal
  builds; the 7-day free-team signing limit means reinstalling weekly during the 14 days.
