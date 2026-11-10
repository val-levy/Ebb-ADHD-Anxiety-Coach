# CARROT Weather: design reference

Source: https://apps.apple.com/us/app/carrot-weather-alerts-radar/id961390574 (Grailr LLC; Apple Design Award, App of the Year).
Screenshots in this folder come from the App Store listing (`urls.txt` lists the originals) and are kept for reference only. Don't ship them.

## What it does well
- **Character voice.** One line of personality sits right under the main number ("Make the most of this nice weather that I generated for you. Or else."). There are 5 selectable personalities, from "professional" to "overkill".
- **One hero, then detail.** Each screen has one big glanceable element (icon, temperature, quip), and the data sits below it in a horizontal hourly strip.
- **Flat illustrated scene.** A layered, rounded landscape (hills, tree, lighthouse) fills the space between the hero and the data. In 6.0, "a garden that grows over time" became the progress motif.
- **Bold, saturated, single-hue backgrounds** (bright blue) with white rounded text and rounded cards. The data pages use a dark navy gradient.
- **Widgets are first class.** The voice line appears inside the widget too, and the widget sizes range from small to large.
- **Deep customization.** Layout editor, 50+ alternate icons, tinted/dark variants, compact sections.
- **Accessibility.** VoiceOver, Larger Text, Dark Interface, Reduced Motion.

## What to take for Ebb
| CARROT | Ebb version |
| --- | --- |
| Snarky AI persona | A warm companion voice. **No snark by default**, because anxious users read sarcasm as judgment (spec principle 1). An optional "playful" personality could come later. |
| Garden grows over time | Fits "no streaks, no guilt": a scene that grows with resets that helped and never wilts. |
| Hero + quip + strip | Home screen = "Want a quick reset?" hero, then a strip of resets |
| Flat illustrated scene | Calm, low-contrast layered shapes. Animate them gently and respect Reduce Motion. |
| Widgets carry the voice | Lock Screen / Home widget: one-tap reset launcher (App Intents) |
| Customization | Later. Alternate icons are cheap and well liked. |

## Swift / native notes
- SwiftUI `Canvas` or layered `Shape`s for the scene. No image assets are needed at first.
- Font: `.rounded` design (`.font(.system(.largeTitle, design: .rounded))`) gives the CARROT-like soft type for free.
- Widgets: WidgetKit + App Intents so a reset can start straight from the Lock Screen.
- Check `@Environment(\.accessibilityReduceMotion)` before animating the scene.
