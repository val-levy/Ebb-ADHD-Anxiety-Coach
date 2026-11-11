# Ebb accounts — design

**Status:** approved and built (branch `feat/accounts`); Sign in with Apple untestable on device until the paid Apple account.

Date: 2026-11-10 · Status: draft for approval · Project 1 of 4 on the road to production
(accounts → hosted backend → friends → App Store).

## Why

Ebb is moving from a demo to a production app. Everything else (friends, cloud sync across phones, the App Store)
needs real people with real accounts. Today every install is a silent anonymous Supabase user with no way to sign in
on another phone, and the profile (name, bio, animal) lives only in on-device storage.

## Goals

- Sign up and log in with **Sign in with Apple only**, through **Supabase Auth**.
- A real `profiles` table (the "profile schema" promised earlier) that replaces on-device profile storage.
- A unique **@username** for every account, chosen at sign-up (friends will use it later).
- The app opens straight into the home screen. No wall at launch.
- Sign out and **delete account** (Apple requires deletion for apps with sign-up).

## Access rules (decided by the user)

| Feature | Without an account |
|---|---|
| Panic button ("I'm panicking right now") | 1st use: free. A sign-up sheet appears **after** the session ends. 2nd use: sign-up sheet appears **before**, with a "Not now" skip. 3rd use onward: **blocked until signed in**. |
| Quick resets, guided sessions | Locked |
| Reflect (brain dump, what helped, patterns) | Locked |
| Profile, achievements, friends, settings | Locked |

"Locked" means tapping it shows the sign-in sheet instead of the feature.

**Safety net (Claude's call):** the screen that blocks the 3rd panic session always shows the 988 crisis line
(call or text) as well as the sign-in button. Nobody in crisis is left with nothing.

**Counting panic uses:** count panic sessions *started* while not signed in, stored on the device (Keychain, so it
survives reinstalling the app). Claude's call: Keychain over UserDefaults because deleting and reinstalling the app would
otherwise reset the count to zero.

## How sign-in works

- On launch the app keeps today's behaviour: if there's no session, sign in anonymously. Anonymous users count as
  **not signed in** for every rule above.
- Sign in with Apple uses the native Apple button (`AuthenticationServices`) and passes Apple's ID token to
  Supabase (`signInWithIdToken`, provider `apple`, with a nonce).
- **Upgrade, don't replace:** if the current user is anonymous, link the Apple identity to that same user, so
  panic sessions done before signing up stay in their history. If that Apple ID already has an account (a returning
  user on a new phone), sign into the existing account instead. The anonymous data from this phone is dropped in that
  case (Claude's call: a merge isn't worth the complexity for one or two panic sessions).
- **First sign-in only:** a short setup sheet asks for an @username (required), a display name (pre-filled from Apple
  if shared), and an animal (the existing picker). Bio is optional and editable later on the Profile screen.
- The session persists across launches (Supabase's default Keychain storage).

## Sign-in sheet (look and feel)

A clay-style bottom sheet that matches the rest of the app: SceneScreen palette, `.clay()` card, Grandstander type,
an animal or two. One short line saying why ("Save your progress and keep what helps you") and the standard black
"Sign in with Apple" button (Apple's design rules require their button styling). The same sheet is reused everywhere
something is locked; only the one-line reason changes.

## Data

New migration `profiles`:

| column | type | notes |
|---|---|---|
| `id` | uuid PK, references `auth.users` on delete cascade | one row per account |
| `username` | text, unique, not null | 3–20 chars, `^[a-z0-9_]+$`, enforced by a DB check; stored lowercase |
| `display_name` | text, not null | 1–40 chars |
| `bio` | text, null | ≤ 160 chars |
| `animal` | text, not null, default `'panda'` | matches the `AvatarAnimal` enum's raw values |
| `created_at` | timestamptz default now() | |

Row-level security:
- You can read, insert and update only your own row.
- **Claude's guess, to revisit in the friends project:** other signed-in users can read `username`, `display_name`
  and `animal` (for finding friends), but **not** `bio`. Implemented with a public view or column-limited policy
  when friends lands. Until then, own-row-only.
- Anonymous users can't create a profile row.

Existing tables (`resets`, `calm_sessions`) keep their per-user RLS. Their rows already belong to the user's id, and
upgrading keeps the same id, so no data migration is needed.

**Delete account:** a Supabase Edge Function (it needs the service role key, which must never ship in the app) that
deletes the calling user from `auth.users`. The cascade removes their profile, resets and calm sessions. It also
revokes their Apple token, which Apple requires. The app confirms twice, then signs out.

## Where the code goes (follows CLAUDE.md: one type per file, no logic in views)

- `Core/Services/AuthService` — anonymous sign-in, Apple sign-in/upgrade, sign out, delete account. The only file
  that touches `client.auth`. `SupabaseService.ensureSignedIn` moves here.
- `Core/Stores/SessionStore` (`ObservableObject`, injected at the root like the other stores) — publishes
  `isSignedIn`, the current `Profile`, and the panic-gate decision.
- `Core/Models/Profile` — mirrors the table.
- `Core/Models/PanicGate` — pure logic: given the uses so far and the sign-in state, returns `.free`,
  `.promptAfter`, `.promptBeforeSkippable` or `.blocked`. Needs a small self-check since it's branchy logic.
- `Features/Auth/` — `SignInSheet`, `ProfileSetupSheet`, `PanicBlockedView`.
- The Profile header switches from `@AppStorage` to `SessionStore.profile`. Any on-device name/bio/animal is used to
  pre-fill the setup sheet once, then cleared.
- Settings gains "Sign out" and "Delete account".

## Setup the user has to do (can't be automated)

- In the Apple Developer account: enable the **Sign in with Apple** capability for `app.ebb.Ebb`. This needs a paid
  Apple Developer Program membership. The current personal team (`F2DD8TWKAQ`) is free and can't use it, so testing
  on the phone needs the paid account.
- Create the Services ID and key for the Supabase Apple provider when moving to the hosted backend (project 2).
  Locally, native ID-token sign-in only needs the bundle id listed as an allowed client id in `config.toml`.

## Non-goals (this project)

- Other sign-in methods (Google, email, password).
- Friends, friend requests, or anything another user can see beyond the guess above.
- Hosted Supabase, backups and production secrets (project 2).
- Moving achievements to the server (they stay computed on the device from the user's own history).

## Anti-goals

- A sign-up wall at launch.
- Ever leaving someone mid-panic with no help on screen.
- The service role key or any secret in the app or in the repo (CLAUDE.md: never commit keys).

## Calls settled after review (Claude's calls)

- **"Signed in" means "has a profile row."** An Apple-linked user who closes the setup sheet is still treated as
  not signed in: locked features stay locked, and tapping one reopens the setup sheet (not the Apple sheet).
- **Sign out** signs straight back in anonymously and the anonymous rules apply again. The Keychain panic counter is
  per device and is never reset, so a signed-out device that has already used its two free sessions is blocked on
  the next one (the blocked screen still shows 988).
- **Returning user on a new phone:** if linking fails because the Apple ID already has an account, ask Apple again
  and sign in normally. A second system prompt is acceptable for this rare path. The leftover anonymous user and its
  rows are cleaned up later by a scheduled job (project 2).
- **Apple token revocation:** the app captures Apple's `authorizationCode` at sign-in and the server stores the
  refresh token now, so nothing is lost. The actual revoke call is switched on in project 2, when the Apple key
  exists. Locally, "delete account" means deleting the user and all their rows.
- CLAUDE.md's "anonymous auth, no signup screen" decision gets updated to match this design when it's built.

## Left to the builder

Copy wording, sheet layout details, username-taken error UX (check availability as they type, debounced), and how
locked tabs look behind the sheet.
