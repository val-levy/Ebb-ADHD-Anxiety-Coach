# iOS app

## Status
In progress: a clickable first iteration of every feature runs in the Simulator.

## Summary
A native SwiftUI iPhone app with 4 tabs: Reset (hero + reset list + demo nudge), Insights (garden + what helped + sample patterns), Unload (brain dump + one next thing), and Settings (guard windows, nudge cap, pause, medication log, 988). Syncs resets to Supabase.

## To do
- [ ] Manually tap through every reset to the end and the rating (only launch + home screen checked so far)
- [ ] Replace the "Demo" pieces with real behavior: snooze/false alarm stored, settings actually read, patterns computed, LLM next step
- [ ] Persist medication doses and brain dump in Supabase (currently in-memory / AppStorage)
- [ ] Apply the design direction (see the design-references item): illustrated scene, voice lines, real garden art
- [ ] Offline queue for failed inserts (currently dropped; see `ponytail:` comment in ResetStore.swift)
- [ ] Lock Screen / Home widget to start a reset (WidgetKit + App Intents)
- [ ] Snooze/pause controls, nudge cap (spec principles 2 & 6)
- [ ] App Store privacy label (health data collected) before release

## Background knowledge
- The user asked for an iPhone app first and declined a Watch app. A Phase 0 Watch logger was started, then deleted.
- iPhone has no HR sensor, so automatic stress detection isn't possible on phone alone. The app is built on the spec's "on-demand tap" path.
- The user requires a modular, one-type-per-file architecture (see CLAUDE.md, **Code architecture**).
- Simulator used: iPhone 17 Pro (`84C68231-E0D3-4CB9-8029-625D03C444A4`), bundle id `app.ebb.Ebb`.
- In xcconfig, `//` starts a comment, so URLs are written `http:/$()/host`.
- Haptics use `UIImpactFeedbackGenerator(.soft)` at each phase change for eyes-free cues.

## Resources
- files: `apps/ios/project.yml`, `apps/ios/Ebb/**` (App, Core, DesignSystem, Features), `apps/ios/Config.example.xcconfig`
- links: https://github.com/supabase/supabase-swift
- references: `.claude/resources/references/design-references/carrot-weather/`
- docs: `.claude/docs/product-spec.md` (Interventions, Design principles)

## Session log
### 2026-11-10 18:26 PST → 2026-11-10 18:30 PST
- Made Preview a check-in a non-consuming test action, so repeated QA does not hit the real daily nudge cap. Simulator relaunch verified; iPhone installed but could not auto-launch while locked.

### 2026-11-10 18:18 PST → 2026-11-10 18:21 PST
- Replaced Reflect's sample PatternRow copy with real seven-day insights from saved reset ratings and nudge responses, plus an honest empty state. See `.claude/progress/weekly-insights/progress.md`.
- Verified: XcodeGen regeneration, Simulator build/install/launch, and connected-iPhone build/install/launch. Generated insight variants still need manual UI checks.

### 2026-11-10 18:01 PST → 2026-11-10 18:13 PST
- Added the Phase 1 nudge behavior layer: previewable check-ins, planned local-notification scheduling, daily cap, pause for today, one-hour snooze, and persisted nudge response labels. See `.claude/progress/phase-1-iphone-behavior/progress.md` for the full implementation and verification record.
- Removed a pre-existing DEBUG launch crash from the repeated Keychain assertion in `PanicGate.selfCheck()`.
- Verified: Simulator and iPhone builds/install/launch succeeded after the crash fix. Notification behavior still needs hands-on verification.

### 2026-11-10 13:48 PST → 2026-11-10 13:51 PST
- Zen tab replaced by Calm tab (see calm-guide). Build succeeded.

### 2026-11-10 13:36 PST → 2026-11-10 13:41 PST
- Built the clickable first iteration: TabView with Reset, Insights, Unload and Settings tabs; a nudge sheet; and a full-screen reset player with "End early" and a rating.
- Restructured into modules at the user's request: 19 files, one type each, under App/Core/DesignSystem/Features. Reset steps moved into the `Reset` model; network calls isolated in `SupabaseService`; state in `ResetStore`.
- Fixed the hero subtitle alignment and tinted the play icons.
- Verified: BUILD SUCCEEDED; launched in the Simulator and screenshotted the home screen (renders correctly); `auth.users` shows the app's anonymous sign-ins.
- Not verified: tapping through the resets, the rating save, and the other tabs (no UI automation run).

### 2026-11-10 13:18 PST → 2026-11-10 13:33 PST
- Wrote the iPhone-only app: 4 resets (breathe, sigh, ground, body) with animated circle + haptics, a Helped/Didn't/Skip rating, a weekly summary, and a 988 link.
- Moved storage from AppStorage to Supabase (anonymous sign-in, insert/select on `resets`).
- Installed XcodeGen via brew, wrote `project.yml`, and generated the project.
- Verified: `xcodebuild` for the iOS Simulator → BUILD SUCCEEDED.
- Not done: no Simulator run and no UI tests.
