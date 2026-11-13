# Ebb

**A calm place to land when your head is loud.**

Ebb is a native iPhone app for people who get overwhelmed. Tap once, do a reset of 90 seconds or less (paced breathing, a physiological sigh, grounding, a body break), rate it with one tap, and see which resets helped this week. For harder moments there are longer guided calm sessions, a brain dump, a quick log, and a small chat that listens and never lectures.

> Ebb is a wellness tool, not a medical device. It does not diagnose, treat or monitor any condition, and it never gives medication advice.

<p>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-SwiftUI-F05138?logo=swift&logoColor=white">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-18%2B-000000?logo=apple&logoColor=white">
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-Postgres%20%2B%20Edge%20Functions-3ECF8E?logo=supabase&logoColor=white">
  <img alt="Status" src="https://img.shields.io/badge/status-prototype-lightgrey">
</p>

---

## What it does

| | |
|---|---|
| **Resets** | Four evidence-based techniques, each one tap to start and 90 seconds or less: paced breathing, physiological sigh, grounding, body break. Rating afterward is always optional. |
| **Guided calm sessions** | Longer, voice-optional walk-throughs for active panic. Big tap targets, calm colors, no alarm. |
| **Reflect** | This week's graphs, which resets helped, and gentle patterns. No streaks, no guilt, no raw stress numbers. Blocks can be reordered by dragging a handle. |
| **Brain dump and log** | Unload thoughts, tag a stressor, keep a private record. |
| **Chat** | A narrowly scoped companion (see [Chat design](#chat-design)). It listens, can log things on request, and points to resets. It does not give advice. |
| **Profile** | An animal avatar, friends, achievements, and settings. |
| **Crisis access** | A 988 link stays reachable, and the chat answers crisis language with fixed text before any model is called. |

The look is deliberately handmade: a claymation landscape, chunky Grandstander lettering, squishy buttons, and a mascot that peeks from the edges. Motion is slow, never per-frame, and respects Reduce Motion, Dynamic Type and VoiceOver.

## Tech stack

| Layer | Choice |
|---|---|
| App | Swift, SwiftUI, iOS 18+, no web views or cross-platform layers |
| Project | [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`apps/ios/project.yml` is the source of truth; the `.xcodeproj` is generated) |
| Backend | [Supabase](https://supabase.com): Postgres 17, Auth, Row Level Security, Edge Functions (Deno / TypeScript) |
| AI | [OpenRouter](https://openrouter.ai) chat completions, called only from an Edge Function |
| Client SDK | `supabase-swift` via Swift Package Manager |
| CI | GitHub Actions |

## Architecture

```
┌────────────┐   supabase-swift   ┌──────────────────────────┐
│  SwiftUI   │ ─────────────────▶ │  Supabase                │
│  iPhone    │   JWT (anon or     │  • Auth (anon / email /  │
│  app       │    signed-in)      │    Apple)                │
└────────────┘                    │  • Postgres + RLS        │
       │                          │  • Edge Functions        │
       │ functions.invoke("chat") └───────────┬──────────────┘
       └──────────────────────────────────────┤
                                              ▼
                                      chat function ──▶ OpenRouter ──▶ model
                                      (runs DB calls as the caller)
```

- **Row Level Security everywhere.** Every user table has RLS enabled with an owner policy on `auth.uid()`. The chat function builds its database client from the caller's own `Authorization` header, so tool writes (log a dose, tag a stressor, save a brain dump) run as the user and cannot touch anyone else's rows.
- **Anonymous first.** Each install starts as an anonymous Supabase user. Signing in links the identity in place (Sign in with Apple, or email and password). Anonymous users get a limited panic ladder counted in the Keychain; chat, profile and friends need an account.
- **Account deletion** goes through the `delete-account` Edge Function, which uses the service role and cascades to every owned row.
- **One network file.** Only `SupabaseService.swift` imports the Supabase SDK.

### Code layout

```
apps/ios/Ebb/
  App/          app entry, root tabs and global sheets
  Core/Models/  content and data types (technique steps, copy tables, DB rows)
  Core/Services/ networking, auth, notifications, spoken guidance
  Core/Stores/  @MainActor state and business logic
  DesignSystem/ theme, clay surfaces, buttons, scene pieces
  Features/     one folder per tab or flow (Home, Reset, Calm, Reflect, Profile, Settings)
supabase/
  migrations/   SQL, applied in filename order
  functions/    chat, delete-account
  tests/        RLS isolation tests
```

The code follows one rule strictly: **one type per file, no logic inside views.** Views lay out and forward taps; stores hold state; services touch the network.

## Chat design

The chat is built to stay small and safe, in `supabase/functions/chat/index.ts`:

1. **Crisis check first.** A regex on the incoming message short-circuits to a fixed 988/911 reply. No model, no tools.
2. **Rate limit.** 30 messages an hour and 150 a day per user.
3. **Prompt assembly.** A scope-locked system prompt, plus:
   - the last few messages,
   - a short **memory** that is rewritten (not appended) every 10 exchanges and capped at 900 characters,
   - one line of the user's own logged patterns, computed on the fly from their data,
   - private pacing cues from time of day and message rhythm, used for tone only,
   - an optional user style note, lowest priority and dropped if it tries to touch the rules.
4. **Model routing.** Routine turns use a cheap model; long or distressed messages use a stronger one (`OPENROUTER_MODEL_HARD`).
5. **Tools.** `log_dose`, `log_stressor` and `save_brain_dump`, validated and run under RLS. A regex backup covers small models that skip or print tool calls.
6. **Output guard.** Replies that contain medication advice, condition claims, prompt leaks or markdown are replaced with a safe fallback.

Requests set `provider.data_collection: "deny"`, and the API key lives only in Supabase secrets.

## Getting started

Requirements: macOS with Xcode, [Supabase CLI](https://supabase.com/docs/guides/cli), [XcodeGen](https://github.com/yonaskolb/XcodeGen), Docker (for local Supabase).

```sh
# 1. Local backend (ports are shifted +100: API :54421, DB :54422)
supabase start

# 2. App config
cd apps/ios
cp Config.example.xcconfig Config.xcconfig   # paste URL and ANON_KEY from `supabase status`

# 3. Generate and open the project
xcodegen generate && open Ebb.xcodeproj
```

Set `DEVELOPMENT_TEAM` in `Config.xcconfig` to run on a device. `Config.xcconfig` is gitignored; never commit it.

To run the chat locally, set the Edge Function secrets `OPENROUTER_API_KEY` (and optionally `OPENROUTER_MODEL`, `OPENROUTER_MODEL_HARD`).

## Testing

```sh
# Row isolation: user B must not see any of user A's rows
supabase/tests/rls.sh http://127.0.0.1:54421 "$(supabase status -o json | jq -r .ANON_KEY)"

# Build the app
xcodebuild -project apps/ios/Ebb.xcodeproj -scheme Ebb \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

CI (`.github/workflows/ci.yml`) runs both on every push and pull request. Small pure-logic types also carry `selfCheck()` assertions that run at launch. There is no XCTest target yet.

## Deploying the backend

```sh
supabase link --project-ref <ref>
supabase db push            # migrations
supabase config push        # auth settings
supabase functions deploy chat
supabase functions deploy delete-account
```

Enable **Anonymous sign-ins** in the dashboard (Auth, Providers). Schema changes always go in a new migration file; never edit one that has been applied.

## Status

Ebb is a working prototype, running on the simulator and a personal device. It is not in the App Store or TestFlight yet.

Known gaps before real users: Sign in with Apple needs a paid Apple developer account; email confirmations are off and need custom SMTP; stress detection via HealthKit is planned but not built; the notification schedules and some Settings controls are placeholders.

## Documentation

- Product vision: [`.claude/docs/product-spec.md`](.claude/docs/product-spec.md)
- Roadmap: [`.claude/docs/roadmap.md`](.claude/docs/roadmap.md)
- Production plan: [`.claude/docs/production-plan.md`](.claude/docs/production-plan.md)
- Copy and safety rules: [`.claude/docs/wording-and-safety.md`](.claude/docs/wording-and-safety.md)
- Contributor and agent rules: [`AGENTS.md`](AGENTS.md)

## License

Copyright © 2026 Val Levy. All rights reserved. See [`LICENSE`](LICENSE). Third-party components keep their own licenses.
