# Zen garden

## Status
dropped: superseded by calm-guide (user decision 2026-11-10). Code deleted; zen_gardens table dropped in 20261110000200.

## Summary
Its own "Garden" tab: a personal sand garden you rake and decorate, which persists over time. Psychology-backed (attention restoration, rhythmic motion, autonomy, no decay). For now it's one garden per user; onboarding comes later.

## To do
- [ ] Hand-test in the Simulator: rake, place/move/long-press-remove elements, smooth sand, relaunch → garden persists
- [ ] Onboarding that personalizes (what calms you: visual/sound/motion, palette, order vs. wildness)
- [ ] Ambient sound chosen in onboarding
- [ ] Earn elements from resets that helped (links the garden to the reset loop)
- [ ] Real illustrated art for the elements (SF Symbols for now)
- [ ] Offline queue (saves are fire-and-forget)

## Background knowledge
- The concept and psychology table are in `.claude/docs/ideas/zen.md`. The user created the file empty and the agent filled it in, so the user may revise it.
- The garden is saved in one `zen_gardens` row per user (items + strokes as jsonb), upserted with `onConflict: user_id`. The `user_id` default comes from auth.uid().
- It saves after each finished gesture, never on every drag frame.
- Strokes are capped at 80 (oldest dropped) to keep the row small. See the `ponytail:` comment in ZenGarden.swift.
- A rake stroke draws 4 parallel tines, offset perpendicular to the direction of travel so they stay parallel through curves.
- This is separate from the Insights "GardenView" (flowers per helped reset). Consider merging the two later.

## Resources
- files: `apps/ios/Ebb/Features/Zen/*`, `apps/ios/Ebb/Core/Models/{GardenElement,PlacedElement,ZenGarden}.swift`, `apps/ios/Ebb/Core/Stores/ZenStore.swift`, `SupabaseService.swift` (garden/save), `supabase/migrations/20261110000100_zen_gardens.sql`, `supabase/tests/rls.sh`
- docs: `.claude/docs/ideas/zen.md`
- references: Attention Restoration Theory (Kaplan & Kaplan, 1989); Self-Determination Theory (Deci & Ryan); `.claude/resources/references/design-references/carrot-weather/` (garden-grows motif)

## Session log
### 2026-11-10 13:43 PST → 2026-11-10 13:45 PST
- Wrote zen.md (concept, psychology, MVP vs. later).
- Added migration `zen_gardens` + RLS, and extended rls.sh to check garden isolation.
- Added 3 models, ZenStore, 2 SupabaseService methods, 5 Zen views, sand colors in Theme, a Garden tab in RootView, and ZenStore injected in EbbApp.
- Verified: migration applied; rls.sh → PASS (resets + gardens isolated); BUILD SUCCEEDED; app launched.
- Not verified: no hands-on UI test. cmux Computer Use daemon unavailable ("toggle Computer Use off and on" in cmux Settings).
