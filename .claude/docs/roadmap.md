# Ebb roadmap (master)

Updated 2026-11-10. The original vision is [product-spec.md](product-spec.md). This file says where each part stands
and what to build next. Each segment has its own doc.

| Segment | Status | Doc |
|---|---|---|
| Built so far | iPhone app, resets, sessions, settings UI, mascot | [built-so-far.md](built-so-far.md) |
| Accounts (Sign in with Apple) | planned, waiting on review | [plan](../../docs/superpowers/plans/2026-11-10-accounts.md) · [spec](../../docs/superpowers/specs/2026-11-10-accounts-design.md) |
| Phase 0: personal prototype | not started | [phase-0-prototype.md](phase-0-prototype.md) |
| Phase 1: MVP | iPhone screens done; Watch, detection, real nudges missing | [phase-1-mvp.md](phase-1-mvp.md) |
| Phase 2: personalization | not started | [phase-2-personalization.md](phase-2-personalization.md) |
| Phase 3: after launch | deferred on purpose | [phase-3-later.md](phase-3-later.md) |
| Business and launch | not started | [business-launch.md](business-launch.md) |

## Suggested order
1. **Phase 1, iPhone-only part:** enforce nudge cap / pause / snooze, store false alarms, local notifications for
   planned nudges, real weekly insight. Small, uses screens that already exist.
2. **Phase 0 prototype:** the cheapest test of the core bet (does stress show in Watch heart rate?). Runs for 14 days,
   so start it early and build other things while it runs.
3. **Accounts:** once reviewed; on-device testing waits for the paid Apple account.
4. **Phase 1, Watch part:** watchOS app, complication, on-wrist resets, then guard-window detection (only if Phase 0 passes).
5. **Phase 2**, then **Business and launch**, then **Phase 3**.

## Gates (from the spec)
- Phase 0 → 1: stress taps match a heart-rate-while-still rise at least half the time.
- Phase 1 → 2: 10 beta users, 3 weeks, under 1 false alarm a day.
- Phase 2 → launch: personalized nudges rated "helped" more than rule-based ones.

## Privacy decision (open)
The spec promises "no server, no account, nothing leaves your phone" and leads its marketing with it. The app now
syncs resets and calm sessions to Supabase, and the accounts plan adds sign-in and server profiles. Decide on purpose:
- **Keep the server:** needed for friends and multiple phones; update the positioning and privacy label, and keep
  raw sensor data (heart rate, motion, detection) on the device only.
- **Go back to local-only:** drop Supabase sync and accounts; friends become out of scope.

## How to keep this current
When a segment changes status, update its row here and the segment doc. Progress logs stay in `.claude/progress/`.
