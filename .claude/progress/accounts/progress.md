# Accounts progress

## 2026-11-10 17:14 — Task 1: profiles migration
- profiles table, RLS (anon insert blocked), username_available(), private.apple_tokens; Apple provider + manual linking in config.toml.
- supabase test db → 9/9 PASS.

## 2026-11-10 17:16 — Task 2: PanicGate + KeychainCounter
- Ladder 0→promptAfter, 1→promptBeforeSkippable, 2+→blocked; signed in→free. Counter in Keychain (survives reinstall).
- selfCheck failed on stub, passes now (sim). iPhone install OK; launch refused because phone was locked.
