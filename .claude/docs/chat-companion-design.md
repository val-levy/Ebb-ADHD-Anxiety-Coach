# Ebb chat companion — design

Date: 2026-11-10 · Status: draft for approval · Depends on: accounts (`2026-11-10-accounts-design.md`)
Sibling project: personal model (`personal-model-design.md`). Both share the data layer in §5.

---

## 1. Why

People with ADHD and anxiety don't fill in forms. They will, however, type "rough night, skipped meds" into a chat.
The companion turns that kind of message into structured logs, and over time it shows the person patterns in
their own data ("on the 4 days you logged a missed dose this month, you also logged poor sleep the night before").
The person decides what, if anything, to do about it.

## 2. The one rule

**Updated 2026-11-10.** The rules for what any Ebb text may say live in
[wording-and-safety.md](wording-and-safety.md). Short version: Claude **may suggest wellness actions** (bedtime,
wind-down, when to reset, caffeine cutoff), always as options and always grounded in the user's own precomputed
patterns or `user_tuning` values. It **may not** make medical claims (condition names as claims, diagnoses,
cardiac terms, accuracy claims), give **medication advice of any kind**, or state correlation as cause.

(This replaces the earlier "never suggest" rule. The original quote is in git history.)

| Surface | May suggest an action? |
|---|---|
| Chat replies (anything Claude writes) | Yes, wellness suggestions phrased as options, per [wording-and-safety.md](wording-and-safety.md). Never medical claims or medication advice. |
| Normal app UI (buttons, nudges, reminders, the Calm tab, meditation reminders) | Yes, same rules. |
| Insight cards written by the AI | Yes, same rules as chat. |

**Crisis exception (my call, flagged for the user):** if a message signals self-harm or suicide risk, the reply
does not follow the normal reply format. It shows a fixed, non-AI app message with the 988 line (call or
text) — the same safety net the accounts spec already uses. This is app UI, not AI advice, so it fits the rule.
The AI's text for that turn is replaced, not shown.

## 3. Goals

1. A chat screen inside the **Reflect** tab where the user types (or dictates with the system keyboard mic)
   free text.
2. Every message is parsed into zero or more **log entries** of fixed kinds (§5.2). The user sees what was
   logged as small chips under their message and can undo or edit any chip.
3. Claude replies with a short acknowledgment plus, when the data supports it, one pattern.
4. A "Patterns" view lists insights generated from the user's data, refreshed weekly (this replaces today's
   placeholder weekly insight).
5. The AI knows the user's context: their medications and schedule, recent logs, Apple Health summaries, recent
   resets and calm sessions, and the profile — so it understands "skipped the morning one".
6. No API key in the app. All model calls go through a Supabase Edge Function.

## 4. Non-goals and anti-goals

**Non-goals (not in this project):**
- Voice chat or text-to-speech replies.
- Image input (photos of meals, pill bottles).
- A drug database or interaction checks. Ebb never knows what a drug does beyond what the user typed.
- Sharing chats with friends or clinicians.
- Tuning breathing, nudges or timing — that's the personal-model project.
- Running any part of this on-device.

**Anti-goals (it fails even if it "works" when):**
- Any AI text makes a medical claim or gives medication advice ([wording-and-safety.md](wording-and-safety.md) §2).
  One instance is a bug at the severity of a crash.
- It sounds like a therapist or doctor. It's a calm, warm wellness coach that's good with numbers.
- It suggests something not grounded in the user's own patterns or `user_tuning` (generic health tips).
- It invents a pattern the data doesn't support, or states correlation as cause ("missing meds causes your bad
  sleep"). Patterns say "alongside", "on the same days", "more often when" — never "because" or "causes".
- It logs something the user didn't say (hallucinated entries). When unsure, it asks or logs nothing.
- It nags, guilt-trips, or moralizes ("only 2 of 7 doses this week").
- Data leaves Supabase + Anthropic, or the API key ships in the app.

## 5. Data

### 5.1 Where it lives

Everything in the user's Supabase Postgres, under RLS (`user_id = auth.uid()`), same pattern as `resets` and
`calm_sessions`. Anonymous users can't use chat (Reflect is already locked without an account per the
accounts spec). Deleting the account cascades everything below.

### 5.2 Log entry kinds

One table, `log_entries`, with a `kind` enum and a typed `data` jsonb validated by a check per kind. Fixed kinds
(the model may only emit these):

| kind | data fields | example text |
|---|---|---|
| `medication_taken` | `medication_id` (uuid, nullable if unknown), `name_text`, `dose_text` (nullable), `taken_at` | "took my adderall at 9" |
| `medication_missed` | `medication_id` (nullable), `name_text`, `scheduled_for` (nullable) | "skipped meds" |
| `meal` | `description`, `size` (`snack`/`meal`/`large`, nullable), `eaten_at` | "had a bagel around 11" |
| `caffeine` | `description`, `amount_text` (nullable), `at` | "3rd coffee" |
| `alcohol` | `description`, `amount_text` (nullable), `at` | "two beers" |
| `sleep_report` | `quality` (1–5, nullable), `hours` (nullable), `night_of` (date), `note` | "barely slept" |
| `mood` | `valence` (−2…+2), `label` (free word, nullable), `at` | "feeling kind of flat" |
| `anxiety` | `level` (0–10, nullable), `at`, `note` | "anxiety through the roof" |
| `focus` | `level` (0–10, nullable), `at`, `note` | "couldn't focus at all" |
| `energy` | `level` (0–10, nullable), `at` | "wiped out" |
| `physical` | `symptom` (free text), `at` | "headache all afternoon" |
| `stressor` | `description`, `at` | "big presentation tomorrow" |
| `activity` | `description`, `duration_min` (nullable), `at` | "went for a run" |
| `plan` | `description`, `planned_for` | "dentist at 3 tomorrow" |
| `note` | `text` | anything worth keeping that fits nothing above |

Times: the model resolves relative times ("last night", "at 9", "this morning") against the user's local time,
which the app sends with every message (ISO-8601 with offset, plus the IANA zone). Levels are only filled when
the user's words imply one; otherwise null. Numeric mapping guide lives in the system prompt (e.g. "through the
roof" → 8–9, "a bit" → 3).

**The user's example**, "rough night, skipped meds", becomes:
1. `sleep_report { quality: 2, night_of: <yesterday>, note: "rough night" }`
2. `medication_missed { name_text: "meds", medication_id: <the only scheduled med, if exactly one>, scheduled_for: <today's dose time> }`

If they have two scheduled meds, the reply asks "Which one — Adderall (8am) or Lexapro (9pm)?" and logs the
entry with `medication_id = null` until answered; the answer updates it.

### 5.3 Tables (new migration `chat_companion`)

```
medications            -- the user's own list; entered in Profile → Medications (app UI)
  id uuid pk, user_id uuid fk auth.users cascade (default auth.uid()),
  name text not null (1–60), dose_text text null (≤40),
  schedule jsonb not null default '[]'   -- [{ "time": "08:00", "days": [1..7] }] local wall-clock times
  active boolean not null default true, created_at timestamptz default now()

chat_threads           -- one per day-ish; a new thread starts after 6h of silence (client decides)
  id uuid pk, user_id, started_at timestamptz default now(), title text null

chat_messages
  id uuid pk, user_id, thread_id fk chat_threads cascade,
  role text check in ('user','assistant','system_notice'),
  body text not null (≤ 4000 chars for user),
  client_sent_at timestamptz not null, tz text not null,
  model text null, guard_result text null,     -- 'pass' | 'rewritten' | 'fallback' | 'crisis'
  created_at timestamptz default now()

log_entries
  id uuid pk, user_id, kind log_kind not null, data jsonb not null,
  occurred_at timestamptz not null,            -- the time the thing happened (indexed)
  source text check in ('chat','manual','import') default 'chat',
  message_id uuid null fk chat_messages on delete set null,
  status text check in ('active','undone','needs_clarification') default 'active',
  created_at, updated_at

insights
  id uuid pk, user_id, kind text ('weekly','chat'),
  body text not null, evidence jsonb not null, -- [{metric, window, n, value}] the numbers behind the sentence
  period_start date, period_end date, created_at,
  dismissed boolean default false

health_daily           -- shared with the personal model; one row per user per local day
  user_id, day date, pk(user_id, day),
  sleep_minutes int, sleep_start timestamptz, sleep_end timestamptz, sleep_efficiency real,
  resting_hr real, hrv_sdnn_ms real, respiratory_rate real, spo2_avg real,
  steps int, active_kcal real, mindful_minutes int, updated_at
```

Indexes: `(user_id, occurred_at desc)` on `log_entries`; `(thread_id, created_at)` on `chat_messages`.
RLS: own-rows `for all to authenticated` on all six, but with **`auth.jwt()->>'is_anonymous' = 'false'`** in the
check so anonymous users can't write (matches the accounts lock). The Edge Function uses the caller's JWT, not
the service role, for every read/write so RLS still applies (§6.4).

`health_daily` is owned by the personal-model project; it's defined here because the chat reads it and whichever
project ships first creates it. HealthKit ingestion is specified in the personal-model doc §5.

### 5.4 What the model sees each turn (the context pack)

Built server-side by the Edge Function, never by the app:

1. **Profile:** display name, pronouns if set (else none — the model never assumes), timezone.
2. **Medications:** active list with schedule.
3. **Last 14 days, summarized:** per day — logs grouped by kind (compact one line each), `health_daily` row,
   resets count + helped count, calm sessions (program, before→after intensity).
4. **Precomputed patterns** (§7) — the model may only cite patterns from this list, with their numbers.
5. **This thread's last 30 messages** (older turns dropped; the logs keep the facts).

Size target: under ~6K tokens for 3–5 above. The stable system prompt is cached (§6.3).

## 6. How a message flows

```
iPhone ──POST /functions/v1/chat {thread_id, text, client_sent_at, tz}──► Edge Function `chat`
  1. verify JWT, reject anonymous (403), rate-limit (§6.5)
  2. insert user chat_message
  3. crisis screen (§6.6) ──hit──► insert system_notice, return {crisis:true}
  4. build context pack (§5.4)
  5. Claude call: structured output {entries[], reply, clarification} (§6.2)
  6. validate entries against per-kind schemas; drop invalid ones (logged server-side)
  7. guard reply (§8) → pass | rewrite once | fallback text
  8. insert log_entries + assistant chat_message in one transaction (rpc)
  9. return {reply, entries:[{id,kind,summary}], guard_result}
```

### 6.1 Edge Function

- Deno/TypeScript, `supabase/functions/chat/index.ts`, Anthropic official SDK
  (`import Anthropic from "npm:@anthropic-ai/sdk"`). Key in Supabase secrets as `ANTHROPIC_API_KEY`
  (`supabase secrets set`), never in the repo, never in `Config.xcconfig`.
- Non-streaming for v1 (replies are short; chips need the whole result anyway). Typing indicator on the client
  covers latency. Streaming is a later upgrade.

### 6.2 The Claude call

- **Model:** `claude-opus-5-5` (the user asked for the "smartest chat"). Thinking adaptive, `output_config.effort`
  `"medium"` (set explicitly; it's Opus 5.5's default). Server-side refusal fallbacks enabled:
  `betas: ["server-side-fallback-2026-07-01"]`, `fallbacks: "default"`; always check `stop_reason` before reading.
- **Output:** structured outputs via `output_config.format` (JSON schema), not forced tool use (forced
  `tool_choice` returns 400 on Opus 5.5). Schema:
  ```json
  { "entries": [ { "kind": "<log_kind>", "occurred_at": "ISO-8601", "data": { } , "confidence": 0.0 } ],
    "clarification": { "question": "string", "entry_index": 0 } | null,
    "reply": "string (≤ 600 chars)",
    "cited_pattern_ids": ["string"] }
  ```
  `data` per kind is a `oneOf` keyed by `kind` with `additionalProperties:false`. Entries with
  `confidence < 0.6` are stored as `needs_clarification` and the question is asked.
- `max_tokens` 4000. No `temperature` (removed on this model).

### 6.3 Prompt caching

Order: `system` (frozen rules + kind guide + examples, ~3–4K tokens, `cache_control: {type:"ephemeral"}`) →
messages. The context pack goes in the **first user turn of the request** after the cache breakpoint, never in
`system`, because it changes daily. No timestamps in `system`. Verify `usage.cache_read_input_tokens > 0` on the
second request in the function's logs.

### 6.4 Auth inside the function

Create the Supabase client with the caller's `Authorization` header so every query runs under RLS as that user.
The service-role key is not used by `chat`.

### 6.5 Limits and cost

- 60 messages per user per day, 8 per minute (counted from `chat_messages`; 429 with a friendly app message).
- User message ≤ 4000 chars (client and server).
- Log `usage` (input, output, cache read) per call into a `chat_usage` table (user_id, message_id, tokens…, cost
  estimate) so cost per user is measurable before pricing (business-launch doc).

### 6.6 Crisis screen

Before the Claude call, a cheap classifier call on `claude-haiku-5-5` (structured output `{risk: none|possible|clear}`)
on the user's message only. `possible` or `clear` → no AI reply; store a `system_notice` and the app shows the
fixed crisis card (988 call/text, "You can keep logging whenever you want"). The text is hard-coded in the app.
A keyword pre-check (list in the function) also triggers it without the model, so an API outage doesn't silence it.

## 7. Patterns and insights

The model never computes statistics. **SQL computes patterns; the model only phrases them.** That's how
"never invent a pattern" is enforced. The same holds for suggestions: every suggestion Claude makes must come
from a precomputed pattern (`cited_pattern_ids`) or a `user_tuning` value passed in the context pack, never from
general knowledge.

### 7.1 Pattern library (Postgres function `compute_patterns(user_id, window_days)`)

Each returns rows `{id, kind, a, b, n_a, n_b, value_with, value_without, window, strength}` only when the
minimum-data rule passes (≥ 6 days with A and ≥ 6 days without A in the window, and |difference| ≥ a per-metric
threshold):

| id | compares |
|---|---|
| `missed_med__next_sleep` | sleep quality / minutes on nights after a missed dose vs. not |
| `poor_sleep__next_anxiety` | mean anxiety/focus logged the day after <6h sleep vs. ≥6h |
| `caffeine_after_14__sleep` | sleep minutes on days with caffeine logged after 14:00 vs. not |
| `meal_gap__anxiety` | anxiety logs within 5h without a meal vs. with |
| `med_time__focus` | focus logs in the hours after a dose vs. the same hours on missed days |
| `hrv_low__panic` | panic/resets on days with HRV below the user's 30-day median vs. above |
| `stressor__resets` | resets on days with a logged stressor vs. not |
| `activity__mood` | mood valence on days with activity vs. without |
| `reset_kind__helped` | which reset kind has the best helped-rate (already shown today; reuse) |
| `calm_program__drop` | mean intensity drop per guided program |

### 7.2 Weekly insight

A Supabase cron (`pg_cron` → Edge Function `weekly-insights`, Sunday 18:00 user-local, batched by timezone) runs
`compute_patterns(…, 28)`, picks the top 3 by strength, asks Claude to phrase each as one sentence under the same
rules + guard, and stores rows in `insights` with the raw numbers in `evidence`. The app's Reflect "Patterns" view
reads `insights`. Each card has "How was this worked out?" showing the evidence numbers in plain words.
Below the data minimum: "Ebb needs about two more weeks of logs to see patterns."

### 7.3 Daily plan and evening check-in

**Daily plan (morning).** When the user opens Reflect for the first time after their wake time (or taps the
"Today" card), the Edge Function `daily-plan` asks Claude to phrase a short plan (≤ 4 lines) from:
`user_tuning` (bedtime target, wake time, meditation/reset slot, quiet windows), last night's `health_daily` sleep,
and caffeine patterns (`caffeine_after_14__sleep`). Items, each only when its source value exists:

- tonight's bedtime target and wind-down time (bedtime − 45 min),
- best reset or meditation time today,
- caffeine cutoff (only if the caffeine pattern passed its data minimum),
- a lighter note after a short night ("you slept less than usual, so today's session is a bit longer").

Claude gets the values as a JSON object and only phrases them; it may not add items. Stored once per day in
`insights` (`kind='daily_plan'`, values in `evidence`). Same guard (§8). Example:
"Morning. You slept 6h 10m, a bit under your usual. Want a reset around 2:45 when your dip usually starts? Bedtime
target tonight: 11:15, wind-down at 10:30."

**Evening check-in.** A local notification (app UI, via `NudgeScheduler`) fires at wind-down time **only** if the
user is heading toward a short night: no sleep yet and `now + their median sleep latency` would leave less than
their estimated sleep need before the wake time. Copy: "Heading toward a short night. Want to start winding
down?" Tap opens a wind-down calm session. Respects quiet hours, the nudge cap and the Personalize toggle.
No check-in when no bedtime target exists yet.

## 8. The medical-claim guard

Rules: [wording-and-safety.md](wording-and-safety.md). Suggestions are allowed; the guard looks only for the
forbidden list. Three layers, every one required:

1. **System prompt:** the allowed/forbidden rules from wording-and-safety.md §1–§3, the "options, never orders"
   framing, the grounding rule (§7), plus 12+ worked ✅/❌ examples (in the plan).
2. **Deterministic filter** on the reply (case-insensitive), any hit fails:
   - **Condition names as claims:** a condition term (`adhd`, `anxiety (disorder|attack)`, `panic (attack|disorder)`,
     `insomnia`, `depression`, `arrhythmia`, `ptsd`, `bipolar`, …) near a claim verb (`detect`, `treat`, `manage`,
     `monitor`, `diagnos`, `cure`, `worsen`, `symptom`, `looks like`, `sounds like`, `sign of`, `you have`).
   - **Medication advice:** an advice verb (`take`, `skip`, `stop`, `start`, `increase`, `decrease`, `lower`,
     `raise`, `double`, `move`, `switch`, `change`, `retime`, `remember to`, `don't forget`) within 6 words of a
     medication word (`med(s|ication)?`, `dose`, `pill`, `prescription`, or any name from the user's `medications`).
   - **Diagnosis phrasing:** `you('re| are) (sleep[- ]deprived|depressed|anxious disorder)`, `you (have|might have|
     may have)`, `detected`, `diagnos`, `this (is|looks like|could be) (a|an) .*(attack|disorder|condition)`.
   - **Cardiac terms:** `arrhythm`, `irregular (heart|rhythm|beat)`, `abnormal (rhythm|heart)`, `afib`, `a-fib`,
     `palpitation`, `cardiac`, `heart (problem|condition|disease)`.
   - **Accuracy claims:** `\d+ ?% (accura|precis|sensitiv)`, `clinically (proven|validated)`, `medical[- ]grade`.
   - **Doctor mention** passes only when the turn's context pack flags an out-of-range metric
     (wording-and-safety.md §3); otherwise `doctor|physician|cardiologist|psychiatrist` fails.
3. **Judge model:** `claude-haiku-5-5` with structured output
   `{medical_claim: boolean, medication_advice: boolean, span: string|null}` given wording-and-safety.md §2 and
   the reply. Wellness suggestions ("want to try a 2-minute reset at 3?") are explicitly marked as passing.

Any hit in 2, or `medical_claim`/`medication_advice` true in 3 → one rewrite call (same model, "rewrite this reply
removing the medical claim or medication advice; keep the logged facts, the pattern and any wellness suggestion")
→ re-check. Still failing → **fallback**: a template built from the entries only ("Logged: missed dose
(Adderall), rough night."). `guard_result` records which path ran. Rate of `rewritten`/`fallback` is a launch
metric (target < 2% / < 0.2%).

Insight sentences and daily plans go through layers 2 and 3 too.

## 9. App (iOS)

- **Reflect tab** gets a top segmented control: **Chat · Patterns · Dump** (Dump = today's brain dump, kept).
  Native `Picker(.segmented)`, clay surroundings. Swipe rules unchanged (only Calm's grid flips modes).
- **Chat screen:** clay bubbles, user right / Ebb left, Grandstander via `ClayFont`, the mascot's face as Ebb's
  avatar. Under each user bubble: entry chips (icon + short summary, e.g. "💊 missed · Adderall"). Tap a chip →
  sheet to edit fields or **Undo** (sets `status='undone'`). Clarification questions show quick-reply chips with
  the options (e.g. the med names).
- Composer: multiline `TextField`, send button, character counter after 3,500. Keyboard mic works (system).
- Empty state: one line, "Tell Ebb how things are going. It'll keep track." — no AI greeting, no suggestion.
- Typing indicator: three bouncing clay dots; respects Reduce Motion (static dots).
- Offline: message queued locally with a "will send when online" tag; no local parsing.
- **Profile → Medications** (app UI): list, add/edit name, dose text, times, days. This is normal UI, so it may
  say "Add your medications so Ebb can understand 'the morning one'".
- Architecture per CLAUDE.md: `ChatStore` (ObservableObject) owns state; `ChatService` in `Core/Services` wraps the
  function call; views have no logic; one type per file.

## 10. Privacy

- The user already chose cloud ("smartest chat"). The privacy screen (first chat open, one time) says plainly:
  messages and your logs are stored in your Ebb account and sent to Anthropic to generate replies; Anthropic
  doesn't train on API data; delete everything any time (Settings → Delete account, already planned, plus
  Settings → Delete chat history).
- `product-spec.md`'s "no server" line is superseded; roadmap privacy decision is marked resolved: cloud.
- No health data in logs/analytics; Edge Function logs only ids, token counts, guard_result.

## 11. Decided by the user vs. my calls

**User decided:** cloud AI, smartest model; parse chat into logs; patterns and insights; (2026-11-10) wellness
suggestions allowed under [wording-and-safety.md](wording-and-safety.md), no medical claims, no medication advice;
character is a calm, warm wellness coach, not a therapist or doctor; daily plan + evening check-in; the data list (meds and timing, nutrition and timing, sleep, stress, daily plans,
HRV, SpO₂, breathing rate, heart rate); it improves as more is given.

**My calls (check these):**
1. Chat lives in Reflect with a segmented control, not a 4th tab.
2. Crisis handling replaces the AI reply with fixed app UI (988).
3. Fixed list of 15 log kinds.
4. SQL computes patterns; Claude only phrases them.
5. Opus 5.5 for chat, Haiku 5.5 for the crisis screen and the guard judge.
6. 60 messages/day cap.
7. Threads split after 6h of silence.
8. Clarifying factual questions are allowed.
9. Evening check-in is a local notification (app UI), not a chat message; daily plan shown on first Reflect open after wake.

## 12. Left to the builder

Exact visual sizes, chip icons, the regex term lists' final wording beyond §8, pattern thresholds' exact numbers
(starting values in the plan), SQL query shapes.
