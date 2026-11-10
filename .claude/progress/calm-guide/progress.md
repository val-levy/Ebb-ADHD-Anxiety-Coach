# Calm guide

## Status
in progress: MVP built and compiles; not hand-tested in Simulator

## Summary
Calm tab: guided, voice-led sessions to get out of fight-or-flight during panic (Peloton-style), replacing the zen garden concept.

## To do
- [ ] Hand-test full flow in Simulator (before → session → after → helped → saved row)
- [ ] Offline queue for session saves (panic often happens offline)
- [ ] Pause button; Reduce Motion check on breathing circle in sessions
- [ ] Onboarding to personalize technique order; consider quick 988 link inside session
- [ ] Better voice (recorded audio) later

## Background knowledge
- Evidence base per technique: .claude/docs/ideas/calm-guide.md
- Personalization: CalmStore.favoriteTechnique moves to the front of the panic core block (CalmProgram.techniques(favorite:)).
- ResetStep.Motion gained `.still` (circle stays put).
- Panic UI uses Theme.panicGradient (indigo), never red.

## Resources
- files: apps/ios/Ebb/Core/Models/{CalmTechnique,CalmProgram,CalmSession}.swift, Core/Stores/CalmStore.swift, Core/Services/{GuideVoice,SupabaseService}.swift, Features/Calm/*
- db: supabase/migrations/20261110000200_calm_sessions.sql, supabase/tests/rls.sh
- docs: .claude/docs/ideas/calm-guide.md

## Session log
### 2026-11-10 13:48 PST → 2026-11-10 13:51 PST
- Deleted zen code; built Calm models/store/voice/views; Calm tab replaces Garden.
- Migration drops zen_gardens, adds calm_sessions + RLS; rls.sh now checks calm_sessions.
- Verified: migration applied, rls.sh PASS, BUILD SUCCEEDED, app installed + launched in Simulator.
- Not verified: tapping through a session by hand.
