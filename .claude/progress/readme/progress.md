# README

## Status
done

## Summary
Public-facing `README.md`: what Ebb is, features, stack, architecture, chat design, setup, tests, deploy, status.

## To do
- [ ] Add screenshots or a short screen recording once on-device captures exist
- [x] License: proprietary, all rights reserved (LICENSE, 2026-11-12)
- [ ] Update the Status section when TestFlight/App Store happens

## Background knowledge
- Wording follows `.claude/docs/wording-and-safety.md`: no condition claims, so the README says "people who get overwhelmed" and carries a not-a-medical-device note.
- Facts come from the code (`chat/index.ts`, migrations, `ci.yml`, `project.yml`), not the old roadmap. The roadmap says "Claude" for chat but the code calls OpenRouter.
- `supabase functions deploy` lines are standard CLI usage; not run in this session.

## Resources
- files: `README.md`

## Session log
### 2026-11-12 16:45 PST → 2026-11-12 16:47 PST
- Added proprietary `LICENSE` (© 2026 Val Levy, all rights reserved); README License section now points to it.
- Note: a notice protects the code, design and text, not the bare idea; repo privacy is the real protection for the idea.

### 2026-11-12 16:30 PST → 2026-11-12 16:35 PST
- Rewrote `README.md` from the 25-line quickstart to a full project README, keeping the original run/test/deploy commands.
- Not verified: setup commands were not re-run; no screenshots included.
