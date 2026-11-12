# Ebb: instructions for every agent

Ebb is an iPhone app for adults with ADHD and anxiety. You tap when you're spiraling, do a reset of 90 seconds or less (paced breathing, physiological sigh, grounding, body break), rate it with one tap, and see which resets helped this week. The full product vision is in `.claude/docs/product-spec.md`. Read it before any product or design work. Where each part stands and what to build next is in `.claude/docs/roadmap.md` (master) and its per-segment docs; update them when a segment changes status.

## Keeping this file current (standing instruction)
When the user gives an instruction meant to last (a rule, preference, convention, decision or process), **add it to this file in the right section in the same turn**, so every future agent follows it. One-off task requests don't belong here; they go in that item's progress.md.

## Before you start any work
1. Read this file in full.
2. Open `.claude/progress/` and find the item you're working on. Read its `progress.md` in full. If the item doesn't exist yet, create it (see **Progress tracking**).
3. If the work involves UI or design, read `.claude/resources/references/design-references/` first.

## Decisions already made (don't re-litigate them; ask the user if you think one is wrong)
| Decision | Detail |
| --- | --- |
| **iPhone app only** | No Apple Watch app for now. The user explicitly declined one. |
| **Swift / SwiftUI** | All app and UI code is native Swift. No React Native, Flutter or web views. |
| **Cloud first (Supabase)** | Data lives in Supabase for now. **On-device chat was evaluated and dropped (2026-11-11):** Apple's on-device model has a ~4k-token context (Apple's docs) and is weaker than the cloud model, so the scope-locked prompt, memory, tools and refusals wouldn't fit or hold. Only revisit for a narrow job (e.g. suggesting a next step), and only if the user asks. This contradicts the spec's "nothing leaves the phone" promise, and the user chose this deliberately. |
| **Accounts: Sign in with Apple + email/password** | Each install starts anonymous; Sign in with Apple links the identity (`linkIdentityWithIdToken`). Signed in = a `profiles` row. Anonymous users get a panic ladder (1st free with prompt after, 2nd skippable prompt, 3rd blocked with 988) counted in the Keychain; brain dump, profile, friends and resets need sign-in. Account deletion goes through the `delete-account` Edge Function. Email + password also works (anonymous users are upgraded in place via `auth.update`, then the session MUST be refreshed so the JWT stops saying `is_anonymous`); password reset is the default email link reopening the app at `ebb://reset`. **Phone-number sign-in was dropped** (needs an SMS provider; most people use Apple). Email confirmations are OFF for the prototype: turn them on with custom SMTP before real users. Row-level security scopes every row to `auth.uid()`. **Paid Apple account flip:** set `EBB_ENTITLEMENTS = Ebb/Ebb.entitlements` in `Config.xcconfig`, enable Sign in with Apple for `app.ebb.Ebb` in the developer portal, then fill the Apple provider `secret` in Supabase. Free team: leave it empty or the phone build fails to sign. |
| **Remote backend** | The app talks to the remote Supabase project `ebb` (ref `bmhzzwzbpakjuybthjis`, the user's personal account, NOT the Lōkahi account). `supabase link` points at it; `supabase db push` / `config push` deploy. `DEVELOPMENT_TEAM` lives in gitignored `Config.xcconfig` (xcconfig comments are `//`). Free tier: no custom email templates. |
| **Chat** | Chat uses OpenRouter from the `chat` Edge Function (tools log doses, stressors, brain dumps as the signed-in user). Requests send `provider.data_collection: "deny"`; the key is the Supabase secret `OPENROUTER_API_KEY`, never in the app or repo; model name in `OPENROUTER_MODEL`. Per-user memory lives in `user_memory` (rewritten every 10 exchanges); each request also adds private pacing cues from message timing and wording (`signalsLine`), used for tone only and never mentioned to the user. Rate limit 30/hr, 150/day. |
| **Monorepo** | Apps live under `apps/` and the backend under `supabase/`. |
| **XcodeGen** | `apps/ios/project.yml` is the source of truth. `Ebb.xcodeproj` is generated and gitignored. Never hand-edit the `.xcodeproj`. |
| **Local Supabase ports shifted +100** | The API is on `:54421` and the DB on `:54422`, because the user runs another local Supabase project on the default ports. Don't stop that other project. |

## Code architecture (binding)
The user requires **modular, object-oriented code where everything has its own space**:
- **One type per file.** The file is named after the type (`ResetRow.swift` holds `struct ResetRow`). Never put several views or classes in one file.
- **No logic embedded in views.** Content and data (titles, steps, copy tables) live in `Core/Models`. Network calls live in `Core/Services`. State and business logic live in `Core/Stores`. Views only lay out and forward user actions.
- **Group by feature.** Each tab or flow gets a folder under `Features/`. Shared look (colors, gradients, radii) lives in `DesignSystem/Theme.swift`, so never hard-code colors in views.
- **Explicit imports.** Each file imports what it uses (`SwiftUI`, `Foundation`, `Supabase`). Only `SupabaseService` imports `Supabase`.
- **Extract early.** Pull out a subview or helper when a section has its own job (e.g. `MedicationSection`, `BreathingCircle`).
- New files are picked up automatically: run `xcodegen generate` after adding or removing files.

```
apps/ios/Ebb/
  App/            EbbApp (entry, owns the store), RootView (tabs + global sheets)
  Core/Models/    AppPage (swipe order: Calm Quick ⇄ Guided ⇄ Reflect ⇄ Settings), CalmMode (quick | guided), Reset (titles, symbols, steps), ResetStep, ResetEntry (DB row),
                  CalmTechnique (evidence-based techniques + steps), CalmProgram (guided sessions), CalmSession (DB row)
  Core/Services/  SupabaseService: the only file that touches the network; GuideVoice: spoken prompts; NextStepSuggester (demo brain-dump → one step)
  Core/Stores/    ResetStore (resets) and CalmStore (calm sessions + personalization): @MainActor ObservableObjects, state + logic
  DesignSystem/   Theme (colors, gradients, radii), ClaySurface (.clay()), ClayCanvas (.clayCanvas()), SquishyButtonStyle + SquishyButton, ClayBar, KeyboardDismisser (tap outside a field hides the keyboard),
                  GrainOverlay, SceneScreen, ClayIconTile, SectionLabel,
                  FloatingModifier (.floating()), PopInModifier (.popIn(order)), DriftModifier (.drift())
    Scene/        LandscapeBackdrop + pieces: HillShape, Triangle, DriftingCloud, FlyingBird, SwayingTree, SwayingFlower,
                  HoppingBunny, Butterfly, SunView (day), MoonView/TwinklingStar/Firefly (night), SurpriseAnimal (Giraffe, Lion, Elephant),
                  SecretMeadow (pull-down easter egg: Panda, Penguin, Flamingo, HotAirBalloon + reused animals)
  Features/
    Home/         HomeView (the single Calm tab: panic hero + Quick/Guided ModePicker + OptionTile grid, then brain dump, past dumps, quick log and chat), ModePicker, OptionTile, NudgeSheet, Unload/ (BrainDump*, QuickLogCard, StressorChips), Chat/ (ChatCard, ChatScreen, ChatBubble)
    Reset/        ResetView (player), BreathingCircle, ResetRatingView
    Calm/         PanicHeroCard, CalmProgressCard, GuidedSessionFlow,
                  IntensityCheckView, GuidedSessionPlayer, SessionProgressBar, TechniqueHeader, SessionControls, HelpedPickerView
    Reflect/      ReflectView (this week's graphs + what helped + patterns, nothing else; blocks are reorderable by dragging a grip handle (gestures only on the handle so scroll stays free) with an insertion line (custom gesture, no system drag preview), order saved via ReflectModule + @AppStorage), HelpedCard, PatternRow, Insights/ (charts)
    Settings/     SettingsView, MedicationSection, CrisisSection
```
Anything labeled **"Demo"** in code is placeholder behavior in the clickable prototype (simulated nudge, sample patterns, rule-based next step, settings nobody reads yet). Replace it with real behavior; don't build on it.

## Product and design rules (from the spec, binding)
- Never show raw stress numbers ("your heart rate is high"). Use invitations like "Want a quick reset?"
- Every reset is one tap to start and takes 90 seconds or less. (Calm sessions are the exception: longer guided walk-throughs for active panic.)
- Panic UI must never add alarm: calm colors (no red), big tap targets, voice guidance optional.
- No streaks and no guilt. Show "resets that helped," never a broken streak.
- Rating after a reset is always optional (keep the Skip button).
- Keep the 988 crisis link reachable. All copy (chat, notifications, UI, App Store) follows `.claude/docs/wording-and-safety.md`; wellness suggestions phrased as options are allowed. The three hardest rules: **no condition claims** (never say Ebb detects, treats, manages or monitors ADHD, anxiety, panic, insomnia, etc.), **no medication advice** (never suggest taking, skipping or retiming a dose, never remind anyone to take meds), and **alerts describe signals, not conditions** ("Your heart rate's up while you're sitting still. Breather?", never "Panic attack detected").
- **Visual style: comfy claymation, inspired by clay.com** (`.claude/resources/references/design-references/clay/`). Main tabs use `SceneScreen` (grainy sky + rolling hills + trees, ClayTitle resting on the meadow just above the panel and moving with it, white rounded panel). Rows use `ClayIconTile` (two-tone colored icon in a pale tile) and `.clay()` white cards. Group labels use `SectionLabel` (small uppercase). Colored heroes get `GrainOverlay`. Buttons squish (global `SquishyButtonStyle`, a PrimitiveButtonStyle that fires only on a clean tap so scrolling never triggers buttons; never swap it for a touch-down press-highlight style). Type is Grandstander (chunky, neat hand-lettering, OFL, static faces SemiBold–Black bundled in Resources/Fonts; user tried Fredoka and preferred Grandstander): always use `ClayFont.*` (e.g. `.font(ClayFont.headline)`), never `.font(.headline)`, and never add `.fontDesign(...)` (it silently swaps custom fonts back to system). Screen titles are `ClayTitle` (white chunky letters with an extruded shadow) pinned to the top of the content panel, so they ride with it when pulled down. **Keep it alive:** hero cards `.floating()`, lists `.popIn(index)` stagger, scenes animate (drifting clouds, flying birds, butterflies, swaying trees/flowers, hopping bunny, an occasional surprise animal). **Light and dark modes are different scenes:** day = sun, birds, butterflies, bunny; night = moon, twinkling stars, fireflies, night palette (landscape colors are dynamic in Theme). **Resets and guided calm sessions live in one tab** (Calm), switched by the Quick/Guided picker; don't split them back into separate tabs. Tabs are **Calm (resets, guided sessions, brain dump, log, chat), Reflect (this week's graphs, what helped, patterns), Profile** (animal avatar picked from the clay animals via `AvatarAnimal`, never photo uploads; about you, friends, achievements; Settings sits behind its gear). Profile data is on-device until the profile schema lands; achievement rules live in `Achievement.all`. Every new screen uses SceneScreen + `.clay()` cards + ClayIconTile, never plain List/Form styling. **Navigation:** a sideways swipe moves along AppPage (handled once, in RootView; on Calm, only swipes that start on the Quick/Guided card grid (`calmModeArea`) flip the mode, swipes anywhere else move a whole tab and keep the mode; keep the native iOS TabView and tab bar, never a custom pager or custom tab bar (user tried one and rejected it); screens must not add competing horizontal swipes; a sideways drag freezes vertical scroll; sideways controls lock the tab swipe only while held via the `tabSwipeLocks` environment counter). Pulling a SceneScreen down keeps the scene fixed and slides the content panel down to uncover SecretMeadow, more hills and animals beneath the scene (Snapchat-style; no clouds), so SceneScreen tabs don't use `.refreshable`. The keyboard must never trap the user: tapping outside a field or dragging the page dismisses it. **Smoothness rule:** never redraw per frame (no TimelineView+Canvas for motion). Draw each piece once (`.drawingGroup()`, padded if blurred) and animate only offset/rotation/scale. Motion stays slow and gentle (calming, never jittery) and every animation must stop or reduce under Reduce Motion. Never copy Clay's actual assets or logo. **Mascot:** the user's avatar animal (`profileAnimal`) is the mascot: `MascotPeek` hides behind edges on every screen and in sessions (never in Settings); first-time tips use `.mascotTip(Tip)`, shown by `TipCoach`: the screen dims except a spotlight on the section, and the full clay mascot drawing (never an avatar tile) stands by a bubble, so nothing is covered undimmed (one at a time per screen, order = `Tip` case order); the ? on each SceneScreen replays only that screen's tips. New sections get a Tip case. Tips never show during a panic session. Leaving the Profile tab pops Settings.
- **Design direction (binding): clay characters.** Design as if a kids'-cartoon / play-dough animator worked at Apple. The Calm option tiles are the reference: solid colored clay lumps with grain (not white cards), a little `ClayFace` character instead of an SF Symbol icon, playful names with plain-word descriptions and a length chip, a separate palette per page, `Theme.claySea` (not purple) for panic/guided in light mode, few things moving. Anything that looks generic or "AI generated" (pale icon squares, gray captions, stock symbols, clinical copy) is wrong. **Faces only on the 8 Calm option tiles (plus panic hero/mode picker/nudge); every other tile, chip and header gets a custom informational `ClayIcon` that fits the item (`ClayIconKind.forSymbol`), never a face and never an SF Symbol (tab bar uses animal avatars).** Full notes: `.claude/resources/design/clay-characters.md`; read it before any UI work and bring new screens in line.
- The voice is warm, **not snarky**. CARROT Weather inspires the design, but its sarcasm reads as judgment to anxious users.
- Respect Reduce Motion, Dynamic Type and VoiceOver.
- Features should be grounded in psychology and personalized: each person calms down in their own way. Note the evidence base in the feature's idea doc.
- Coordinates saved for drawings or placement are normalized to 0...1, so they look the same on every screen size.

## Repository map
```
CLAUDE.md                     this file: rules for every agent
README.md                     human quickstart (run, test, deploy)
.gitignore                    ignores Config.xcconfig, the generated .xcodeproj, and Supabase temp files
.github/workflows/ci.yml      CI: builds the iOS app + runs the RLS test against local Supabase
apps/ios/
  project.yml                 XcodeGen project definition (targets, Supabase SPM package, Info.plist keys)
  Ebb/                        app source, one type per file (see **Code architecture**)
  Ebb/Info.plist              generated by XcodeGen; carries SUPABASE_URL / SUPABASE_ANON_KEY from xcconfig
  Config.example.xcconfig     committed template for Supabase URL and key
  Config.xcconfig             local secrets, GITIGNORED; never commit it
supabase/
  config.toml                 local Supabase config (anonymous sign-ins ON, ports shifted to 544xx)
  migrations/                 SQL migrations, applied in filename order. Never edit an applied one; add a new file.
  tests/rls.sh                proves users can't read each other's rows. Run it after any schema/policy change.
.claude/                      agent workspace (see below)
```

## `.claude/` workspace
```
.claude/
  docs/                       product and planning documents
    product-spec.md           the original Ebb spec (vision, rules, roadmap, risks). Read-only reference.
    ideas/                    the user's feature ideas, one file each (calm-guide.md = guided panic sessions; zen.md = superseded zen garden)
  progress/                   one folder per work item, each with a progress.md (see below)
  resources/
    design/                   Ebb's own design work: mockups, color/type tokens, icon drafts, screen specs
    references/               outside material we learn from but don't ship
      design-references/      apps we draw visual/UX inspiration from, one subfolder per app
        carrot-weather/       first inspiration: README.md (analysis + what Ebb takes) + App Store screenshots
        clay/                 current visual direction (clay.com): claymation landscape, grain, icon tiles
    tools/                    scripts and helper utilities for development (not shipped in the app)
      make-icon.swift         renders the app icon (clay seedling on hills) into Ebb/Assets.xcassets/AppIcon.appiconset
```
Rules:
- Put new inspiration in `resources/references/design-references/<app-name>/`. Each one gets a `README.md` covering the source link, what the app does well, and what Ebb takes from it. Reference assets are copyrighted, so **never ship them in the app**.
- Put new specs, plans and research in `docs/`.
- Keep scripts in `resources/tools/` and mention each one in its item's progress.md.

## Progress tracking (mandatory)
Every distinct item of work (feature, screen, backend change, research task) has its own folder:
`.claude/progress/<item-name>/progress.md` (kebab-case name, e.g. `ios-app`, `supabase-backend`, `onboarding-screen`).

**After any and all work on an item, update its progress.md before you finish.** No exceptions, even for small changes. Prepend a new session entry (newest first) and keep the top sections current.

Template:
```markdown
# <Item name>

## Status
<one line: not started | in progress | blocked (why) | done>

## Summary
<what this item is and why it exists, 2-3 lines>

## To do
- [ ] remaining tasks, most important first

## Background knowledge
- facts, gotchas and decisions a new agent needs (why something is the way it is)

## Resources
- files: paths touched or relevant
- links: docs, URLs
- references / inspiration: paths under .claude/resources/
- docs: paths under .claude/docs/

## Session log
### <YYYY-MM-DD HH:MM TZ> → <YYYY-MM-DD HH:MM TZ>
- what was done (concrete: files, commands, results)
- what was verified and how (build, test output)
- what was NOT done or left unverified
```
Get timestamps from `date "+%Y-%m-%d %H:%M %Z"`. Record the start before you begin and the finish when you end.

## Common commands
```sh
supabase start                                    # local backend (from repo root)
supabase/tests/rls.sh http://127.0.0.1:54421 "$(supabase status -o json | jq -r .ANON_KEY)"
cd apps/ios && xcodegen generate && open Ebb.xcodeproj
xcodebuild -project apps/ios/Ebb.xcodeproj -scheme Ebb -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

## Working rules
- Verify before claiming done: build the app, and run `rls.sh` after DB changes. State honestly what was not verified.
- Schema changes go in a new migration file. Every new table needs RLS enabled and an owner policy.
- Keep it simple: add files and abstractions only when there's a real need, and prefer the platform's built-in features (SwiftUI, WidgetKit, App Intents).
- Commit small and often: one commit per item of work, detailed messages. Never push or deploy unless asked.
- Never commit `Config.xcconfig` or any key.

- **Every time the app is rebuilt/restarted on the simulator, also build, install and relaunch it on the user's connected iPhone** (user instruction).
