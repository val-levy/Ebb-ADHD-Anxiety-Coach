# Built so far

As of 2026-11-10 · Master: [roadmap.md](roadmap.md)

iPhone app (SwiftUI, iOS 17) at `apps/ios`, Supabase backend at `supabase/`. Details live in CLAUDE.md.

## Features
- **Calm tab:** "I'm panicking right now" guided session (back button, adjustable breathing pace), Quick resets
  (paced breathing, physiological sigh, grounding, body break) and Guided programs, before/after intensity, what helped.
- **Reflect tab:** brain dump, what helped, patterns (sample insight text).
- **Profile tab:** animal avatar, friends card (placeholder), achievements, Settings behind the gear.
- **Settings:** breathing pace 1–10, editable guard windows / planned nudges / medications, nudge cap, pause today,
  988 call and text.
- **Mascot:** your avatar animal peeks around screens and teaches each screen with dimmed-spotlight tips; ? replays.
- **Clay look:** animated meadow scenes (day/night), Grandstander type, squishy buttons, Reduce Motion respected.
- **Navigation:** native tab bar; sideways swipes move between tabs; swipes on the Calm card grid flip Quick/Guided.

## Backend
- Anonymous Supabase auth; `resets` and `calm_sessions` with per-user row-level security.

## Beyond the original spec
Mascot, profile/achievements/friends, guided calm programs, Supabase sync, and the accounts work.
