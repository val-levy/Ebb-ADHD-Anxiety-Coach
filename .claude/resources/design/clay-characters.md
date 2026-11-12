# Clay characters: Ebb's design direction

The brief (from the user): **as if someone who made cartoons for young kids / play-dough animation worked at Apple and designed this app.** Apple-level polish and restraint, kids'-cartoon warmth. The Calm tiles are the reference implementation. Anything that looks like generic AI app output (pale icon squares, gray captions, stock SF Symbols, clinical copy) is wrong.

## What the tiles do (copy this everywhere)
- **Solid colored clay lumps**, not white cards: `.clay(color, radius: Theme.heroRadius)` + `GrainOverlay`, white bold text on top. Each page has its own palette (`Theme.quickPalette`, `Theme.guidedPalette`) so pages feel different.
- **Characters, not icons:** a little pressed-clay face (`ClayFace` drawn from a `FaceMood`: sleepy / happy / open eyes, smile / o / flat / grin / wave mouths, rosy cheeks) in a translucent white circle. Mood matches the activity (puffing "o" for breathing, grin for the body break, shiver wave for cold). Prefer a face or drawn clay figure over an SF Symbol wherever a hero icon is needed.
- **Names are playful, descriptions are plain.** Tile title = fun and calming (Slow Tide, Sigh Balloon, Pebble Hunt, Noodle Break, Soft Landing, Tiny Roots, Mind Playground, Cool Splash); the line under it says in plain words what you do ("Two sips in, one big sigh out"); length is a chip ("60 sec", "4 min"). The real technique name lives inside the session. Panic keeps its plain, unmissable title.
- **Chunky type:** titles `ClayFont.title3`, details `ClayFont.footnote`, no dotted shorthand ("60s · ..."), no clinical words.
- **Calm color:** panic and guided use `Theme.claySea` (sea-glass blue by day, lavender at night). Never red. Purple does not suit the light scene.
- **Less on screen:** group into labelled sections (`SectionLabel`), one thing floats (the panic pill), no clay-inside-clay, compact panic pill instead of a big hero.

## Still to bring into this style
Cards lower on Calm (brain dump, past dumps, log, chat), Reflect cards, Profile, Settings; Quick/Guided toggle icons (SF Symbols); tab bar stays native.

## Files
`Core/Models/FaceMood.swift`, `DesignSystem/ClayFace.swift`, `Features/Home/OptionTile.swift`, `Features/Calm/PanicHeroCard.swift`, `DesignSystem/Theme.swift` (palettes, `claySea`).
