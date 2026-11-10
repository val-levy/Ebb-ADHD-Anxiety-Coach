# Design references

## Status
In progress: first reference collected.

## Summary
Collecting and analysing apps that inspire Ebb's look and feel, and turning them into concrete SwiftUI direction.

## To do
- [ ] More references from the user as they're shared
- [ ] Distil the references into Ebb design tokens (color, type, spacing) in `.claude/resources/design/`
- [ ] Sketch the home screen: hero + "Want a quick reset?" + reset strip + growing-garden scene

## Background knowledge
- CARROT Weather is the starting inspiration (user's choice).
- Keep from it: one hero element per screen, rounded type, saturated backgrounds, a flat illustrated scene, widgets that carry the voice, and "a garden that grows over time".
- Reject: the snark. Anxious users read sarcasm as judgment (spec design principle 1).
- The App Store page HTML has no screenshot URLs; they came from `https://itunes.apple.com/lookup?id=961390574`.
- The screenshots are Grailr's copyright and are for reference only.

## Resources
- references: `.claude/resources/references/design-references/carrot-weather/` (README.md, screenshot-01…10.png, urls.txt)
- links: https://apps.apple.com/us/app/carrot-weather-alerts-radar/id961390574
- docs: `.claude/docs/product-spec.md` (Design principles)

## Session log
### 2026-11-10 13:28 PST → 2026-11-10 13:33 PST
- Created the `.claude/` structure (docs, progress, resources/{design,references,tools}).
- Fetched the App Store listing and downloaded the 10 iPhone screenshots via the lookup API; viewed 3 of them.
- Wrote the CARROT README: what it does well, what Ebb takes from it, and Swift implementation notes.
- Copied the product spec into `.claude/docs/product-spec.md`.
