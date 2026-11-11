# Remote Supabase + email auth + synced notes

## Status
in progress (prototype on simulator; phone install pending, device was unavailable)

## Summary
App points at the remote Supabase project `ebb` (ref bmhzzwzbpakjuybthjis, user's personal account, not Lōkahi). Email+password sign-in added alongside Apple; brain dump synced to a `notes` table under RLS.

## To do
- [ ] Install latest build on the iPhone (it was unavailable at last attempt) and test: profile Save, brain-dump restore after reinstall, forgot-password link
- [ ] Sign in with Apple: needs a PAID Apple developer account (free team can't enable the capability, so the phone can't produce a token). Then follow AGENTS.md "Paid Apple account flip". Apple secret is believed unnecessary for the native ID-token flow (unverified)
- [ ] Chat UI (table chat_messages exists with RLS; no service/model code yet)
- [ ] Phone-number sign-in: dropped by user (most will use Apple)
- [ ] Custom SMTP: Supabase free tier + default email can't customise templates and rate-limits reset emails

- [ ] Before real users: enable email confirmations + custom SMTP (reviewer flagged unverified-email pre-hijacking)

## Background knowledge
- Anonymous→email upgrade uses auth.update(user:) then MUST refreshSession(): the old JWT keeps is_anonymous=true and profiles insert RLS returns 403 (verified with curl).
- Email confirmations off (config.toml, pushed with `supabase config push`).
- NoteStore keeps UserDefaults "dump" as offline cache; debounced 1s upsert; anonymous users don't upload.
- Agent permissions deny any .env* file.

- Password reset: default email link -> ebb:// URL scheme (project.yml CFBundleURLTypes, redirect allowed in config.toml) -> SessionStore.handleURL -> NewPasswordSheet. Code-based reset was impossible: email templates can't be edited on the free tier with default SMTP.
- DEVELOPMENT_TEAM lives in Config.xcconfig (gitignored, personal team F2DD8TWKAQ); xcconfig comments are // not #.
- supabase/migrations 0500 notes, 0600 chat_messages; both verified via curl against remote (other user sees [], forged insert 403).

## Resources
- files: Core/Services/AuthService.swift, Core/Services/SupabaseService.swift, Core/Stores/{SessionStore,NoteStore}.swift, Core/Models/Note.swift, Features/Auth/{SignInSheet,EmailSignInFields}.swift, Features/Reflect/BrainDumpCard.swift, supabase/migrations/20261110000500_notes.sql, apps/ios/Config.xcconfig (gitignored)

## Session log
### 2026-11-11 15:42 PST
- Scaling the brain dump list (advisor-reviewed): table was never the problem; client fetch/render was. Reflect card shows 3 newest + "See all" -> BrainDumpsScreen (LazyVStack, keyset pagination on created_at, 20/page, hasMore/loadMore, no 50 cap). SceneScreen content is a plain VStack, so the full list uses LazyVStack inside it. Extracted ClayBackButton (Settings uses it too). Verified on remote: 45 rows paged 20/20/5, 45 unique ids. rls.sh now covers brain_dumps + chat_messages; PASS against remote. AGENTS.md accounts row + remote backend row updated. Phone + simulator rebuilt; screens not yet seen by agent or user, and lazy loading in SceneScreen unverified on device.
- Chat (user chose a new chat screen pushed from Reflect, free-tier model). Advisor design, not built: bounded prompt = rolling summary (user_memory table, owner RLS, rewritten by Edge Function after each chat) + last ~20 messages + last ~5 dumps + this week's helped ratings; no embeddings yet. Provider call isolated in one Edge Function file. OPEN: free-tier terms (does the free tier train on prompts? must research current terms, not from memory); system prompt must carry .claude/docs/wording-and-safety.md (no condition claims, no med advice, 988); write .claude/docs/ideas/ chat doc with evidence base.
### 2026-11-11 15:39 PST
- Merged "Save for later" into the one "Give me one small step" button: it computes the step, saves the dump, clears the draft. Built + launched on phone and simulator; not yet tapped by the user.
- User asked for chatbot advice that learns from past chats/info. No chatbot exists (NextStepSuggester is a rule-based demo). Needs decisions: where it lives, LLM provider/key via Edge Function, consent for sending history. Not started.
### 2026-11-11 15:36 PST
- Brain dump history: migration 0700 renames notes -> brain_dumps (many rows per user, id pk, created_at). NoteStore -> BrainDumpStore (local draft + saved dumps; draft clears only after a successful save). New "Save for later" button, "Past brain dumps" card (BrainDumpHistoryCard + BrainDumpRow: 2-line preview, tap to expand, trash to delete), new Tip .pastDumps. Verified on remote with curl: owner-only read, forged insert 403, other user's delete removes nothing. Simulator + phone built; phone launch refused (locked), UI not yet seen by agent or user.
### 2026-11-11 15:29 PST
- Security review follow-up: local brain dump is now tagged with its owner (UserDefaults "dumpOwner"); NoteStore.load() clears it and cancels a pending save when the signed-in user changes, and runs on every profile change. Not tested with two real accounts on a device.
- Accepted risk, not changed: email confirmations are OFF (user wanted a 10-minute prototype, no SMTP), so an email can be claimed without verifying it. Turn on enable_confirmations (and custom SMTP) before real users.
### 2026-11-11 15:26 PST
- Added forgot password (link flow), chat_messages table, DEVELOPMENT_TEAM in Config.xcconfig. Builds clean; simulator updated; phone not installed (unavailable). Reset email request returns 200 but the full link round trip was not tested (needs a real inbox on the phone).
### 2026-11-10 23:46 PST
- "Couldn't save" again: the email user existed (not anonymous) with no profile. A replayed insert as that user in SQL (rolled back) succeeded, so it was the client. The persisted session held a JWT minted while anonymous; on relaunch the app went straight to setup with it, and RLS returned 403. Fix: createProfile refreshes the session first. Rebuilt for iPhone + simulator; not yet confirmed by the user.
### 2026-11-10 23:44 PST
- Linked remote project, pushed 6 migrations, config, delete-account function.
- Verified remotely with curl: auth settings, anon upgrade + profile insert (403 old token / 201 refreshed), notes RLS (other user sees [], forged insert 403).
- Built and launched on iPhone + simulator. Email sign-in on device not yet confirmed by user. Remote rls.sh not run (curl checks instead).
