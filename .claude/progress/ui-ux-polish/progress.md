# UI/UX polish

## Status
in progress

## Summary
A cohesive refinement pass across Ebb’s primary iPhone flows, improving visual hierarchy, intentional use of space, interaction clarity, and consistency without losing the calm claymation character.

## To do
- [ ] Audit Calm, Reflect, Profile, Settings, and modal states on the Simulator.
- [ ] Prioritize and implement the highest-friction improvements.
- [ ] Validate on Simulator and iPhone, including Dynamic Type and Reduce Motion where relevant.

## Background knowledge
- The visual system is comfy claymation: SceneScreen, clay cards, icon tiles, Grandstander type, and slow gentle motion.
- Sheets should use space intentionally and share a consistent clay-panel treatment.
- The wellness voice must be optional, warm, and non-clinical.

## Resources
- files: `apps/ios/Ebb/Features/`, `apps/ios/Ebb/DesignSystem/`
- docs: `.claude/docs/product-spec.md`, `.claude/docs/wording-and-safety.md`
- references: `.claude/resources/references/design-references/clay/README.md`

## Session log
### 2026-11-11 19:00 PST
- Calm tab declutter, nothing removed: panic is now a compact lavender clay pill (54pt round icon, title, one line, chevron) instead of the big hero; option tiles smaller (118pt, 44pt icon); sections labelled Reset now / Your progress / Unload / Track and talk; dropped the extra `.floating()` on brain dump (only panic floats); Log card dose button is a flat tile, not clay-in-clay. Built and launched on phone; not seen on device yet, simulator not checked.
- OpenRouter activity (user screenshot, 18:40): routing confirmed live. Llama 3.3 70B handles routine turns ($0.06), Sonnet 5.5 the heavy ones ($0.04), Mistral Nemo ~$0. Key spend $0.10 of the $1 limit.
### 2026-11-11 18:35 PST
- Patterns was the only multi-card set: `PatternsSection` now draws all patterns inside ONE `.clay()` card (`PatternRow` is a plain row), so every Reflect block is a single item with one handle. NOT verified on device.
### 2026-11-11 18:25 PST
- Fix: for "What helped" and "Patterns" the ≡ handle sat on the label row, outside the card. `ReflectModule.hasLabel`; those two now put the handle on the card (top-right of the card / first pattern card). NOT verified on device.
### 2026-11-11 18:00 → 18:20 PST
- Reflect layout is now an **Edit layout / Done** mode: handles (≡) and the drag only exist while editing, so normal use has no gestures on blocks. Hint + tip text updated.
- Auto-scroll while dragging: `SceneScreen` owns a `ScrollControl` (App/ScrollControl.swift; `ScrollPosition` + offset/viewport, exposed via `\.scrollControl`); `ReflectBlocks` (new, holds the logic; `ReflectView` is just SceneScreen { ReflectBlocks() }) runs a 16 ms loop that scrolls when the finger is within ~130pt of the top or ~170pt of the bottom. `ReflectDrag` (Core/Models) keeps the block under the finger as the page scrolls; self-checks added.
- **Deployment target raised 17 → 18** (project.yml) because `ScrollPosition.scrollTo(y:)` is iOS 18.
- Verified: sim + phone builds, installed. NOT verified on device: scroll in normal mode, drag, auto-scroll speed/edge zones.
### 2026-11-11 17:50 → 17:58 PST
- Scroll still dead with long-press arming + simultaneous drag on each block. Fallback: a ≡ grip (44pt) at each block's top-right is the ONLY draggable spot (immediate DragGesture); no gestures on the blocks themselves. Tip/hint text now says "drag the handle". NOT verified on device. If scroll is STILL dead, the cause is not the gestures (suspect the frames preference / overlay) and needs a bisect.
### 2026-11-11 17:35 → 17:45 PST
- Fix: Reflect would not scroll after the custom drag. Cause: `LongPress.sequenced(DragGesture)` on every block swallowed the scroll. Now `onLongPressGesture` arms a block (fails when the finger moves, so scroll is untouched), a simultaneous `DragGesture` moves only an armed block, and `.scrollDisabled(dragging != nil)` freezes scroll only while one is held.
- Fix: the ? button seemed dead on Reflect because its tip (`.helped`) sat on the 7th block, off screen. The tip now attaches to whichever block is first (`FirstBlockTip`), text says to press and hold to move blocks.
- NOT verified on device (scroll, drag, ? button); builds + install succeeded.
### 2026-11-11 17:20 → 17:30 PST
- Reflect reorder reworked: no system drag box. Custom long-press (0.35s) then drag gesture in `ReflectView`; the block stays as is, lifts with a shadow and follows the finger; a teal insertion line shows the gap it will land in; release snaps it there. Logic in `ReflectModule` (`gap`, `moving(toGap:)`, self-checks); block frames via `ModuleFramesKey`. Tab swipe locked while dragging (`tabSwipeLocks`).
- NOT verified on device: drag feel, whether vertical scroll stays still during the drag. Known limit: no auto-scroll at screen edges, so moving far means several shorter moves.
### 2026-11-11 17:08 → 17:12 PST
- Reflect is modular: `Core/Models/ReflectModule.swift` (enum of 8 blocks, order saved in `@AppStorage("reflectOrder")`, repair + move logic + `selfCheck()` run in DEBUG). `ReflectView` renders blocks in saved order; press-and-hold a block, drag onto another to move it (`.draggable` + `.dropDestination`, system drag so it does not fight scroll or the tab swipe). VoiceOver "Move up/down" actions, "Reset order" button.
- Verified: simulator + phone builds succeed, installed and launched on phone. NOT verified: drag feel on device, drop highlight, tip spotlight after reorder.
### 2026-11-11 17:50 PST → 18:05 PST
- Reflect is now only the old "This week" screen (charts, What helped, Patterns); `WeekSummaryCard` and `InsightsScreen` deleted. Brain dump, past dumps, quick log and chat moved to the bottom of the Calm tab (`HomeView`); files moved to `Features/Home/Unload` and `Features/Home/Chat`, back buttons now say "Calm". Tips `brainDump`, `pastDumps`, `chat` belong to the Calm screen, `helped` to Reflect (anchored on the first chart); `Tip.selfCheck` updated.
- Verified: simulator build succeeds. Not verified: layout on a device/simulator screenshot, tip order on screen.
### 2026-11-11 17:15 PST → 17:35 PST
- Built (committed, NOT yet deployed): model routing in `chat/index.ts` (`isHard`: 30+ words or 2+ distress words -> `OPENROUTER_MODEL_HARD`, else `OPENROUTER_MODEL`; unset = same model) and an optional "How the chat talks" style note (`chat_style` table + RLS, `ChatStyleStore`, `ChatStyleSection` in Settings). The note is appended last as lowest-priority DATA; the prompt says it can only change tone/wording, and the function drops any note that mentions scope, rules, medication, prompts, tools etc. (`STYLE_BAD`, mirrored in `ChatStyleStore.willBeIgnored` so the UI says so). Output guards (`safeReply`) still run, so refusals can't be bypassed.
- Verified: simulator build succeeds. NOT verified: migration push, function deploy, rls.sh, live routing/style behavior, phone build (auto-mode classifier blocked `supabase db push` / `functions deploy`; user must run them).
- Decision: on-device (Apple Intelligence) chat dropped; ~4k-token context and a small model can't hold the scope-locked prompt, tools and memory. Recorded in AGENTS.md.
### 2026-11-11 17:00 PST → 17:10 PST
- Chat now gets private pacing cues (`signalsLine` in `supabase/functions/chat/index.ts`): local time of day (client sends `tz`), gap since their last message (>2h = treat earlier feelings as past, ask how they are now), reply latency (slow = thinking hard, give space), message length, hedging words (unsure = easier questions, "no rush"). Cues only steer tone; the prompt forbids mentioning them or turning them into labels, numbers or conclusions (wording-and-safety rules).
- `SupabaseService.chat` sends `tz`. Deployed the function; tested live with a throwaway account (deleted): replies stay warm and short for hedged/terse input. Phone + simulator builds succeeded, app installed and launched on the phone.
- Not verified: the >2h gap and slow-reply branches (need real waits); the heuristics are crude (ponytail: regex hedge count, median latency).
### 2026-11-11 17:50 PST
- Chat made supportive: SUPPORT step (validate with soothing words + ONE specific follow-up question, 2-3 sentences / 60 words), no narrating of logging, one "Noted." only. Server strips narration, collapses repeated "Noted.", and parses/hides tool calls the model prints as text in either wrapper form (skips guessed "Other"). Extra stressor trigger words (can't switch off, piling, nobody gets me, lonely). Live-tested with throwaway accounts (deleted). Medication/off-topic still refuse.
### 2026-11-11 17:20 PST
- Chat: per-user rate limit (30/hr, 150/day, 429 "busy"), summarizer max_tokens. OpenRouter key has a $1 limit (user set). Flat-reply cause found: llama sometimes prints a tool call as text in `content`; my leak guard then replaced the whole reply. Now such blobs are parsed, run through `runTool` and stripped. Verified live (throwaway account deleted).
### 2026-11-11 17:00 PST
- Chat model switched to `meta-llama/llama-3.3-70b-instruct` (secret set by user; code default updated). History deduped/last 8, examples marked shape-only. Guard trips now return a neutral "I'm here" line instead of the refusal; removed `add` from the condition regex (false positives). Live-tested with throwaway account (deleted). Known: "I'm so tired of everything" / "my friend and I had a fight" fall back to "I'm here. Want to tell me a bit more?" (guard or empty reply, cause not isolated; no log access).
### 2026-11-11 16:40 PST
- Pushed `user_memory` migration and deployed `chat` (new strict prompt + guard). Tested live with a throwaway account (deleted): refusals, crisis 988, med/diagnosis/injection all correct. mistral-nemo skips tool calls, so added `detectLogs` regex backup (first-person past-tense dose; stressor only with a "weighing" phrase + tag keyword) and strip of unearned "Noted." and wrapping quotes. Memory rewrite itself still untested live (needs 20 messages).
### 2026-11-11 16:20 PST
- Chat prompt rewritten as a scope-locked spec in `supabase/functions/chat/index.ts`: fixed REFUSAL and CRISIS texts, crisis regex pre-check (no model call), post-reply guard (`safeReply`: med-advice, condition-claim, leak, markup, length), temperature 0.2, max_tokens 220. NOT deployed, NOT tested live (needs user go-ahead; memory migration also not pushed).
- Chat window now blank on every enter/exit (`ChatStore.reset()`, `ChatScreen` onAppear/onDisappear); server still keeps last 20 messages + memory for the model. Built and installed on phone; sim build passes.
### 2026-11-11 16:45 PST
- Chat memory. Migration `20261111000200_user_memory.sql` (one row per user, body <= 1000 chars, RLS). `chat` function: injects the memory (<= 900 chars) plus a computed line of the user's own patterns (best helped reset this month, top stressor this week) into the system prompt; every 10 new exchanges (20 rows) it rewrites the memory with one extra cheap call (replace, never append; run via EdgeRuntime.waitUntil). iOS: `MemoryStore`, `MemorySection` in Settings ("What Ebb remembers": edit/save/clear), service methods, account-swap guard.
- Verified: sim + phone builds; `rls.sh` now PASSES locally (local DB had been missing migrations; `supabase migration up` fixed it), including user_memory.
- NOT done: migration NOT pushed to remote and function NOT redeployed (waiting for user OK); memory rewrite and Settings card untested live; `deno check` of the function not possible locally (supabase-js npm resolution), so the new function code is type-unchecked.

### 2026-11-11 16:25 PST
- Chat deployed and working. Free models failed (llama :free removed; gemma 429 upstream; nemotron blocked by data policy), so `OPENROUTER_MODEL=mistralai/mistral-nemo` (~$0.03/M tokens, secret on the remote). Verified with a throwaway account (deleted after): dose + Work tag logged, medication-advice question declined. Function returns only fixed error codes (`busy`, `model unavailable`); detail goes to server logs.
- Not verified on the phone UI.

### 2026-11-11 16:05 → 16:08 PST
- Chat with OpenRouter (free model, `provider.data_collection: "deny"`, model in env `OPENROUTER_MODEL`). Edge Function `supabase/functions/chat/index.ts`: auth like delete-account, RLS-scoped client, tools `log_dose`, `log_stressor`, `save_brain_dump` (rows get `source: chat`), last 20 messages as memory, wording-and-safety system prompt. Anonymous users get 403.
- iOS: `ChatMessage`, `ChatStore` (afterActions refreshes dumps + logs), `SupabaseService.chatMessages/chat`, `Features/Reflect/Chat/` (ChatScreen, ChatBubble, ChatCard on Reflect), `Tip.chat`. Sim and phone builds pass.
- Also this stretch: life_logs migration pushed; LogStore account-swap fix.
- NOT done: function NOT deployed, no OpenRouter key set (user must create account, disable free-model training, run `supabase secrets set OPENROUTER_API_KEY=...`, then OK `supabase functions deploy chat`). Free-model tool-calling and rate limits unverified. rls.sh still unverified. Chat UI untested on device. ScheduleItem "medication reminder" comment still stale.

### 2026-11-11 16:00 PST
- Four new insight boxes on the This week screen: Time of day (from resets), Stressors this week, Medication log (7-day dots), Doses and stressors (avg stressors/day with vs without a logged dose; worded as the user's own days side by side, never cause). Manual capture via QuickLogCard on Reflect (dose button + stressor chips). New `life_logs` table (migration 20261111000100, RLS owner policy, rls.sh extended), LogStore, LogEntry, LogInsights (selfCheck). `source` column already allows 'chat' for later.
- NOT done: migration NOT pushed to remote (logging silently fails until `supabase db push`); rls.sh not run; chat parsing (no chat exists yet); not visually checked. Phone install worked, launch refused (locked).
- Flag: `ScheduleItem.swift` doc comment mentions a "medication reminder", which conflicts with the no-reminders rule.
### 2026-11-11 15:54 PST
- Insight graphs (Swift Charts, built in): shared InsightCard frame + ResetsPerDayChart + CalmDropChart under Features/Reflect/Insights/, data shaped by DailyCount and CalmDropPoint (Core/Models, with a selfCheck for DailyCount). InsightsScreen lists them; add a graph = new view wrapping InsightCard + one line. No axis numbers (never raw stress numbers), empty days are quiet. Built sim + phone; not visually checked. Google Health styling details were not findable, structure only.
### 2026-11-11 15:51 PST
- Reflect layout option 3 (journal-first): pill, past dumps, one WeekSummaryCard linking to new InsightsScreen (HelpedCard + PatternsSection, extracted). Dropped the .patterns tip; .helped tip now sits on the summary card. No horizontal carousel (would fight the tab swipe). If it doesn't land, fall back to option 1 (Journal|Insights picker, tap-only). Built sim + phone; not visually checked.
### 2026-11-11 15:50 PST
- Researched journaling/mood apps for a Reflect layout pass; notes in design-references/journaling-apps/README.md. No code changed; layout proposal awaiting user pick.
### 2026-11-11 15:48 PST
- Brain dump pill trailing icon: mic.fill → bubble.left.and.bubble.right.fill (chat). Rebuilt sim + phone.
### 2026-11-11 15:47 PST
- Brain dump is now a compact pill (BrainDumpCard) that opens BrainDumpSheet (full-height editor, keyboard up, one-button step+save, Close). Built sim + phone, installed and launched on phone; not visually checked yet.
### 2026-11-11 15:45 PST
- BrainDumpCard header icon: tray.and.arrow.down.fill → cloud.fill (softer, comfier). Built sim + phone, installed on phone; launch refused (phone locked), not visually checked.
### 2026-11-10 23:48 PST
- Settings "everything is a bubble" fix: Account/Crisis/Schedule used Section outside a List, so .padding().clay() applied to every child (titles, rows, footers each got a raised bubble). Converted all three to SettingsCard (one card per section). Swipe-to-delete never worked outside List; schedule rows now have a long-press Remove. Built + installed on iPhone and simulator; not visually checked by agent (Settings not screenshotted).
### 2026-11-10 19:05 PST → 2026-11-10 19:07 PST
- Increased SettingsCard padding and group spacing, and raised minimum row height to reduce the compressed feel.
- Restored navigation with a clay back button in the Settings scene header.
- Verified: Simulator build/install/launch and iPhone build/install succeeded. The phone was not relaunched after install.

### 2026-11-10 18:59 PST → 2026-11-10 19:00 PST
- Began the Settings conversion: replaced its stock Form canvas with the shared SceneScreen and added `SettingsCard` for breathing and check-in controls. Existing schedule, account, and crisis controls retain their behavior while their row styling is the next refinement.
- Verified: XcodeGen regeneration, Simulator build/install/launch. iPhone build/install succeeded; auto-launch was denied while locked.

### 2026-11-10 18:51 PST → 2026-11-10 18:56 PST
- Audited the Calm screen in the Simulator. Fixed a global interaction/layout issue: iOS's floating tab bar overlaid the final scroll content, so `SceneScreen` now reserves 92pt below every tab’s content.
- Identified Settings as the largest remaining visual inconsistency: it still uses stock Form sections. Its controls need a dedicated clay-card conversion next, retaining their existing scheduling behavior.
- Verified the tab-bar clearance and Account section build in Simulator. iPhone installed; automatic launch was blocked while locked.

### 2026-11-10 18:51 PST → in progress
- Started a user-requested holistic UI/UX polish pass after syncing the latest account controls to the Simulator and iPhone.
