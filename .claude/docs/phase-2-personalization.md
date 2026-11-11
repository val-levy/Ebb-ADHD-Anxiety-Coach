> **Superseded in part (2026-11-10):** the model now runs nightly on the server, not on the device. See [personal-model-design.md](personal-model-design.md) and [chat-companion-design.md](chat-companion-design.md).

# Phase 2: Personalization

Status: **not started** · Source: product-spec.md, "MVP scope" · Master: [roadmap.md](roadmap.md)

## Goal
Nudges tuned to each person, learned on their own phone, rated "helped" more often than the rule-based ones.

## Missing
- **Nightly model:** a small per-user model (logistic regression or gradient boosting, Create ML / Core ML)
  retrained on the iPhone while charging, from nudge labels and on-demand taps. Updated thresholds go back to the Watch.
- **Medication baselines:** the medication list exists in Settings (`@AppStorage("medications")`) but nothing uses it.
  Learn separate resting baselines for on- and off-medication hours.
- **Body-break nudge:** the Body break reset exists; nothing detects near-zero movement for 2+ hours to trigger it.
- **Low-threshold days:** short sleep or low overnight HRV (HealthKit summaries) lowers the threshold that day.
- **Novelty rotation:** rotate haptic patterns and nudge wording so they don't fade into the background. Every
  variant follows [wording-and-safety.md](wording-and-safety.md) §4–§5.

## Depends on
Phase 1 storing every nudge with its label, and the Watch detector accepting updated thresholds.

## Gate
Personalized nudges are rated "helped" more often than rule-based ones.
