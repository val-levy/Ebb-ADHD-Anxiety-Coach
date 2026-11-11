# Accounts progress

## 2026-11-10 17:14 — Task 1: profiles migration
- profiles table, RLS (anon insert blocked), username_available(), private.apple_tokens; Apple provider + manual linking in config.toml.
- supabase test db → 9/9 PASS.

## 2026-11-10 17:16 — Task 2: PanicGate + KeychainCounter
- Ladder 0→promptAfter, 1→promptBeforeSkippable, 2+→blocked; signed in→free. Counter in Keychain (survives reinstall).
- selfCheck failed on stub, passes now (sim). iPhone install OK; launch refused because phone was locked.

## 2026-11-10 17:17 — Task 3: AuthService + SessionStore
- Profile/Username models, AuthService (Apple link → identity_already_exists → fresh sign-in), SessionStore (offline-safe start, panic gate, requireSignIn).
- Sim: app opens to home, no asserts.

## 2026-11-10 17:18 — Task 4: sign-in + profile setup sheets
- SignInSheet (clay card, Apple button, Not now), ProfileSetupSheet (400ms availability check, 23505 → taken), AppleNonce. DEBUG launch arg -authSheet signIn|setup.
- Sim screenshots: both sheets render. Apple sign-in untestable without paid account.
