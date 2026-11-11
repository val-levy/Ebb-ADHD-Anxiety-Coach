# Weekly insights

## Status
done

## Summary
Replaces Reflect's placeholder pattern rows with concise, on-device summaries of the person's saved resets and check-in responses from the last seven days.

## To do
- [ ] Hand-test all generated insight paths and the empty state with realistic saved data.

## Background knowledge
- Insight copy must describe the person's own recorded patterns, never a condition or causal health claim.
- Ebb uses the phrase “resets that helped,” not streaks or guilt framing.
- Clay cards and icon tiles are already provided by `PatternRow`.

## Resources
- files: `apps/ios/Ebb/Core/Stores/ResetStore.swift`, `Core/Services/SupabaseService.swift`, `Features/Reflect/ReflectView.swift`
- docs: `.claude/docs/phase-1-mvp.md`, `.claude/docs/wording-and-safety.md`
- references: `.claude/resources/references/design-references/clay/README.md`

## Session log
### 2026-11-10 18:18 PST → 2026-11-10 18:21 PST
- Added `WeeklyInsight` and `WeeklyInsightBuilder`. Copy is generated only from saved seven-day reset and nudge-event history: strongest rated reset, busiest reset day (two or more), or false-alarm feedback. The builder caps the list at two factual, non-clinical reflections.
- `ResetStore.load()` now fetches nudge history alongside resets and publishes the generated insights. `ReflectView` replaces sample rows with insight cards or an honest empty state.
- Updated the Phase 1 roadmap/docs to mark weekly insight generation built.
- Verified: XcodeGen regeneration; simulator build/install/launch; connected-iPhone build/install/launch. Not hand-verified: all generated copy paths and the empty state.

### 2026-11-10 18:18 PST → in progress
- Began weekly-insight implementation after reviewing the Phase 1 progress, current Reflect UI, wording rules, and clay reference.
