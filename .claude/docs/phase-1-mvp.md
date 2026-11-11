# Phase 1: MVP

Status: **partly built (iPhone screens only)** · Source: product-spec.md, "MVP scope" · Master: [roadmap.md](roadmap.md)

## Goal
Ebb notices stress during guard windows and offers a reset on the wrist within about a minute, with a nudge cap,
snooze and one-tap feedback, plus a real weekly insight on the iPhone.

## Already built
- All resets as iPhone screens: paced breathing, physiological sigh, grounding, body break (`Core/Models/Reset.swift`).
- Panic and guided calm sessions, brain dump, what-helped picker.
- Settings UI: guard windows (editable), planned nudges, nudge cap stepper, "Pause for today", 988 call/text.
- Planned local notifications: enabled planned-nudge times are scheduled for the next week, up to the daily cap.
- Nudge controls: the daily cap, pause-for-today and one-hour snooze suppress/reconcile pending notifications.
- NudgeSheet responses: accepted, dismissed, snoozed and false-alarm responses persist in `nudge_events`; the Preview a check-in button provides a safe manual test path.

## Missing
| Piece | Today | Needed |
|---|---|---|
| Apple Watch app | none | watchOS target, complication for the on-demand tap, haptic breathing/sigh/grounding on the wrist |
| Watch ↔ iPhone | none | WatchConnectivity, events queued on the Watch |
| Detection ("Stress signals") | none | Rule on the Watch: heart rate 20+ bpm above resting while still for 60 s (rolling 60 s windows), conservative start |
| Guard windows | stored in `@AppStorage("guardWindows")`, unused | Start a session during each enabled window; cap ~3 h a day; stop below 30% battery |
| Nudges | Planned local notifications plus a manual preview path | Real trigger from a future detector; copy per wording-and-safety.md §4–§5 |
| Nudge cap | Applied when scheduling and presenting check-ins | Enforce from actual detector events too |
| Pause for today | Cancels planned notifications and resets automatically the next day | Apply to future detector events too |
| Snooze / False alarm | Snooze cancels planned notifications for 1 h; false alarm persists as a label | Use false alarms to adjust the future detector threshold |
| Feedback | rating after resets exists | Store helped / didn't help / false alarm per nudge for Phase 2 training |
| Weekly insight | sample text in ReflectView | Compute from history, e.g. "Spikes cluster Tuesday afternoons; breathing helped 4 of 5 times" |

## Design rules that apply (product-spec.md "Design principles")
- Alerts follow [wording-and-safety.md](wording-and-safety.md) §4: describe the signal, not a condition ("Your heart
  rate's up while you're sitting still. Breather?"), every alert opens a reset, Settings label "Stress signals".
- False alarms cost more than misses: start conservative.
- One tap, under 90 seconds, on the wrist.

## Gate
10 beta users keep it on for 3 weeks with **under 1 false alarm a day**.

## Suggested order
1. iPhone-only wins (no Watch needed): compute a real weekly insight from reset and nudge history; hand-test the
   notification permission, scheduled delivery, cap, pause and snooze on-device.
2. watchOS target + complication + on-wrist resets (on-demand path works from day one).
3. Guard-window sessions + rule-based detection (after Phase 0 passes).
