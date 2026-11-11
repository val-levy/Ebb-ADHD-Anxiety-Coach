# UI/UX polish

## Status
in progress

## Summary
A cohesive refinement pass across Ebb’s primary iPhone flows, improving visual hierarchy, intentional use of space, interaction clarity, and consistency without losing the calm claymation character.

## To do
- [ ] Audit Calm, Reflect, Profile, Settings, and modal states on the Simulator.
- [ ] Prioritize and implement the highest-friction improvements.
- [ ] Validate on Simulator and iPhone, including Dynamic Type and Reduce Motion where relevant.

## Background knowledge
- The visual system is comfy claymation: SceneScreen, clay cards, icon tiles, Grandstander type, and slow gentle motion.
- Sheets should use space intentionally and share a consistent clay-panel treatment.
- The wellness voice must be optional, warm, and non-clinical.

## Resources
- files: `apps/ios/Ebb/Features/`, `apps/ios/Ebb/DesignSystem/`
- docs: `.claude/docs/product-spec.md`, `.claude/docs/wording-and-safety.md`
- references: `.claude/resources/references/design-references/clay/README.md`

## Session log
### 2026-11-10 18:59 PST → 2026-11-10 19:00 PST
- Began the Settings conversion: replaced its stock Form canvas with the shared SceneScreen and added `SettingsCard` for breathing and check-in controls. Existing schedule, account, and crisis controls retain their behavior while their row styling is the next refinement.
- Verified: XcodeGen regeneration, Simulator build/install/launch. iPhone build/install succeeded; auto-launch was denied while locked.

### 2026-11-10 18:51 PST → 2026-11-10 18:56 PST
- Audited the Calm screen in the Simulator. Fixed a global interaction/layout issue: iOS's floating tab bar overlaid the final scroll content, so `SceneScreen` now reserves 92pt below every tab’s content.
- Identified Settings as the largest remaining visual inconsistency: it still uses stock Form sections. Its controls need a dedicated clay-card conversion next, retaining their existing scheduling behavior.
- Verified the tab-bar clearance and Account section build in Simulator. iPhone installed; automatic launch was blocked while locked.

### 2026-11-10 18:51 PST → in progress
- Started a user-requested holistic UI/UX polish pass after syncing the latest account controls to the Simulator and iPhone.
