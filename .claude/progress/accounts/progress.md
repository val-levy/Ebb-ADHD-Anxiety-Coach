# Accounts progress

## 2026-11-10 18:50 — Settings account controls
- Account section now remains visible when anonymous with a `Sign in with Apple` action; signed-in profiles retain their handle, Sign out, and Delete account controls.
- Simulator build/install/launch OK. iPhone build/install OK; automatic launch blocked because device was locked.

## 2026-11-10 17:25 — Tasks 6–7, final review
- Task 6 (cc7f129): header/settings read server profile; single-flight ensureSignedIn. Sim mascot = lion from profiles row.
- Task 7 (f29ccf6): delete-account fn (curl 401 / 200+rows gone / 403 anon); entitlement behind EBB_ENTITLEMENTS; CLAUDE.md, spec, roadmap updated.
- Sim build OK; iPhone build+install OK, launch refused (phone locked). Not verified: Apple sign-in on device, 3 live panic taps.

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

## 2026-11-10 17:20 — Task 5: gating
- Panic ladder in SessionStore.panicTapped; PanicBlockedView (988 call/text + Sign in); LockedGate on resets, guided rows, brain dump, profile header, friends. Settings gear stays open.
- Sim: builds, blocked screen screenshot OK.
