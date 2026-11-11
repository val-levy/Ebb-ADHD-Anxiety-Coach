# Ebb wording and safety rules

Date: 2026-11-10 · Status: **source of truth** · Applies to: chat, notifications, app UI, Watch, App Store listing,
marketing. Other docs link here instead of repeating these rules.

Basis: FDA General Wellness guidance (January 2026) and App Store Review Guideline 1.4.1. Ebb stays a
general-wellness product: it may encourage healthy habits (sleep, rest, breathing, routine) but makes no claim to
diagnose, treat, manage or monitor a disease or condition.

---

## 1. Allowed: wellness suggestions, phrased as options

Ebb may suggest things. It always offers, never orders.

- **Sleep:** target bedtime and wake time, wind-down reminders, "heading toward a short night" check-ins.
- **Daily rhythm:** when to do a reset or meditation, focus blocks, breaks, caffeine cutoff, all from the user's
  own patterns.
- **Framing:** "might help", "want to try…?", "your best days looked like…", "based on your patterns". Every
  suggestion is optional and can be ignored without consequence.
- **Grounded:** a suggestion comes from the user's own precomputed patterns or the personal model's `user_tuning`
  values. Never invented, never generic health advice.

## 2. Forbidden in any output

Chat, notifications, app UI, Watch, App Store listing, marketing:

1. **Condition names as something Ebb detects, treats, manages or monitors:** ADHD, anxiety disorder, panic
   disorder, insomnia, depression, arrhythmia, and the like. Ebb may be *for* people with ADHD ("built with ADHD
   brains in mind") but never claims to treat or manage it.
2. **Diagnoses or diagnosis-like statements:** "you're sleep deprived, which worsens your ADHD", "panic attack
   detected", "this looks like an anxiety attack".
3. **Medication advice of any kind:** never suggest taking, skipping, changing or retiming a dose, and never remind
   anyone to take medication. Showing the user's own patterns involving medication timing is allowed ("on days you
   logged your dose after noon, you slept 50 min less").
4. **Accuracy claims:** "detects stress with 95% accuracy", "clinically proven".
5. **Anything cardiac-sounding:** "abnormal rhythm", "irregular heartbeat", "heart problem".
6. **Correlation stated as cause:** "caffeine causes your bad nights" ❌; "your bad nights often followed late
   coffee" ✅.

## 3. Pointing to a professional (allowed)

Replaces the old ban. When a metric is far outside the user's **own** range (e.g. resting HR well above baseline
for several days), Ebb may say:

> "This is well above your usual. If you feel unwell, consider checking in with a doctor."

No diagnosis, no condition name, no guess at the reason. Only attached to an out-of-range metric, never as a
generic sign-off.

## 4. Detection alerts

- **Describe the signal, not a condition:** "Your heart rate's up while you're sitting still. Breather?" ✅ ·
  "Panic attack detected" ❌.
- **Every alert offers an action** that opens a reset. No warning-only alerts.
- **Settings label:** "Stress signals". Never "Anxiety monitoring" or "Panic detection".
- **User control stays:** nudge cap, quiet hours, sensitivity, and "False alarm" feedback that retrains the model.

## 5. Wording table

| Area | ✅ Say | ❌ Never say |
|---|---|---|
| Sleep | "Your best days followed ~7h 40m of sleep. Want a 11:15pm bedtime tonight?" | "You're sleep deprived. You need more sleep for your ADHD." |
| Sleep check-in | "Heading toward a short night. Want to start winding down?" | "Insomnia warning: go to bed now." |
| Wind-down | "Wind-down time. A slow breathing session might help." | "Do this to treat your insomnia." |
| Daily timing | "Your afternoon dip usually starts around 3. Want a 2-minute reset at 2:45?" | "You must reset at 3pm." |
| Focus | "Your longest focus blocks were late mornings. Want to block 10–11:30?" | "This will fix your ADHD focus problems." |
| Caffeine | "On days with coffee after 2pm you slept 40 min less. Want a 2pm cutoff reminder?" | "Caffeine is causing your anxiety." |
| Medication | "On days you logged your dose after noon, you slept 50 min less." | "Take your meds earlier." / "Time to take your medication." |
| Detection alert | "Your heart rate's up while you're sitting still. Breather?" | "Panic attack detected." |
| Detection alert | "Heart rate's been up a while. Want a 60-second reset?" | "Irregular heartbeat detected." |
| Out of range | "This is well above your usual. If you feel unwell, consider checking in with a doctor." | "This could be an arrhythmia. See a cardiologist." |
| Settings label | "Stress signals" | "Anxiety monitoring" / "Panic detection" |
| App Store copy | "A calm companion for busy minds. Quick resets when stress builds." | "Manages ADHD and anxiety. Detects panic attacks with 95% accuracy." |

## 6. Crisis handling (unchanged)

Keep the crisis classifier, the keyword pre-check and the fallback exactly as in
[chat-companion-design.md](chat-companion-design.md) §6.6. The 988 call/text path stays reachable from Settings.
Crisis replies are not wellness suggestions and are exempt from §1 framing.

## 7. Disclaimer

Shown in onboarding and in the Terms:

> "Ebb is a wellness tool, not medical advice. It doesn't diagnose or treat any condition."

Before launch, a lawyer reviews this doc and the App Store listing (checklist item in
[business-launch.md](business-launch.md)).

## 8. Where it's enforced

- Chat: system prompt, deterministic guard and judge in [chat-companion-design.md](chat-companion-design.md) §8.
- Personal model UI text: [personal-model-design.md](personal-model-design.md) §2.
- Detection and nudges: [phase-1-mvp.md](phase-1-mvp.md), [product-spec.md](product-spec.md).
