# Phase 1 iPhone behavior

## Status
done

## Summary
Turns the Phase 1 iPhone nudge controls from prototype UI into persisted, enforceable behavior: planned local notifications, daily cap, pause, snooze, and false-alarm feedback.

## To do
- [ ] Hand-test notification permission, delivery, cap, pause, snooze and all sheet responses on the Simulator and an iPhone.
- [ ] Hand-test Reflect's weekly-insight copy and empty state on the Simulator and an iPhone.
- [ ] Apply the same controls to future signal-detector nudges.

## Background knowledge
- Alerts must describe a signal rather than a condition and must be calm, optional invitations.
- The app currently uses Supabase plus anonymous sessions; RLS is the security boundary for new event rows.
- The UI is claymation-inspired and must preserve its current design-system components.

## Resources
- files: `apps/ios/Ebb/Core/Stores/`, `apps/ios/Ebb/Core/Services/SupabaseService.swift`, `apps/ios/Ebb/Features/Home/NudgeSheet.swift`, `apps/ios/Ebb/Features/Settings/SettingsView.swift`, `supabase/migrations/`, `supabase/tests/rls.sh`
- docs: `.claude/docs/phase-1-mvp.md`, `.claude/docs/roadmap.md`, `.claude/docs/wording-and-safety.md`
- references: `.claude/resources/references/design-references/clay/README.md`

## Session log
### 2026-11-10 18:44 PST → 2026-11-10 18:47 PST
- Redesigned NudgeSheet to use its panel intentionally: clay reset hero, clear full-width primary action, and bottom utility actions. Preview now uses a consistent 72%-height sheet with a visible drag handle.
- Applied the matching clay-canvas, spacious panel treatment to sign-in, profile setup, and animal picker sheets; retained native delete confirmations because their destructive system semantics are clearer.
- Verified: Simulator build/install/launch and connected-iPhone build/install/launch succeeded. Popup layout is not yet hand-reviewed on both devices.

### 2026-11-10 18:26 PST → 2026-11-10 18:30 PST
- Fixed Preview a check-in silently doing nothing after several uses: previews had been counted toward the real daily cap. They now always open and do not change the cap; planned and future signal check-ins retain the cap/pause/snooze rules.
- Verified: Simulator build/install/launch succeeded. Connected-iPhone build and install succeeded; automatic launch was denied because the phone was locked.

### 2026-11-10 18:01 PST → 2026-11-10 18:13 PST
- Added migration `20261110000400_nudge_events.sql`: `nudge_events` stores origin and shown/accepted/dismissed/snoozed/false-alarm outcomes, with owner-only RLS. Extended `supabase/tests/rls.sh` to prove a second anonymous user cannot read nudge events.
- Added `NudgeEvent`, `NudgeOrigin`, `NudgeOutcome`, `NudgeScheduler`, `NudgeStore`, and the AppDelegate notification bridge. The store owns the daily cap (default 3), today-only pause, one-hour snooze, planned notification reconciliation for the next 7 days, and race-safe response persistence.
- Replaced the demo nudge trigger with `Preview a check-in`; NudgeSheet now records every response. Settings now drives real cap/pause state and reschedules after planned-nudge edits.
- Fixed a pre-existing DEBUG launch crash: `PanicGate.selfCheck()` tried to assert a persistent Keychain counter every appearance. The static ladder assertions remain; the inappropriate launch-time Keychain assertion was removed.
- Verified: XcodeGen regeneration; Simulator build succeeded; Simulator app installed/launched after the crash fix; device build succeeded; installed/launched on the connected iPhone; `supabase migration up` applied the new migration; RLS test passed.
- Not hand-verified: notification permission and scheduled delivery, every sheet response, cap/pause/snooze behavior, or the final app UI on either device.

### 2026-11-10 18:01 PST → in progress
- Started the Phase 1 iPhone behavior implementation after reviewing project rules, roadmap, product wording requirements, and clay design reference.
