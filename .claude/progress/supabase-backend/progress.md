# Supabase backend

## Status
In progress: running locally and tested. No hosted project yet.

## Summary
The cloud data store for Ebb. Its one table, `resets`, logs each reset and its rating, and row-level security restricts each row to its owner.

## To do
- [ ] Create a hosted Supabase project; run `supabase link` and `supabase db push`; enable Anonymous sign-ins in the dashboard
- [ ] Put the hosted URL and key in a Release xcconfig
- [ ] Rate-limit anonymous sign-ups (config.toml `anonymous_users` rate limit) before public beta
- [ ] Decide the data retention/deletion policy (health data)

## Background knowledge
- The user chose cloud compute "for now". On-device compute is a later engineering phase. This intentionally departs from the spec's privacy promise.
- The anon key ships inside the app, so **RLS is the only security boundary**. Every new table needs RLS and an owner policy.
- The policy uses `(select auth.uid())` rather than `auth.uid()`, so Postgres evaluates it once per query instead of once per row.
- Local ports were shifted +100 (54421 API, 54422 DB, 54423 Studio) because another local Supabase project of the user's holds the defaults. Don't stop it.
- The local anon key is the standard Supabase demo key and isn't secret.

## Resources
- files: `supabase/config.toml`, `supabase/migrations/20261110000000_init.sql`, `supabase/tests/rls.sh`, `.github/workflows/ci.yml`
- links: https://supabase.com/docs/guides/auth/auth-anonymous, https://supabase.com/docs/guides/database/postgres/row-level-security
- docs: `.claude/docs/product-spec.md` (Platform, legal, and business risks)

## Session log
### 2026-11-10 13:48 PST → 2026-11-10 13:51 PST
- Added 20261110000200_calm_sessions.sql (drops zen_gardens, adds calm_sessions + RLS). rls.sh PASS.

### 2026-11-10 13:44 PST → 2026-11-10 13:45 PST
- Added `zen_gardens` migration; rls.sh now also checks garden isolation → PASS.

### 2026-11-10 13:22 PST → 2026-11-10 13:33 PST
- Ran `supabase init`, enabled anonymous sign-ins, and shifted the ports after a port 54322 conflict.
- Migration: `reset_kind` enum + `resets` table + index + RLS "own rows" policy.
- Wrote `rls.sh` (two anonymous users; B must not see A's row) and a CI workflow (db + ios jobs).
- Verified: `supabase start` OK; `rls.sh` → PASS: rows isolated per user.
- Not done: CI has never run (no git repo).
