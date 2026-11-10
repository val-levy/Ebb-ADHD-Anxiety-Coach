# Clay style

## Status
in progress: Clay-inspired pass applied to Home and Calm; builds; Home checked by screenshot

## Summary
User asked (2026-11-10) for the app to feel "more comfy, playful, almost play-dough and clay like". Implemented as a small design system so every screen gets it.

## To do
- [ ] Hand-check scrolling over cards no longer triggers taps
- [ ] Icons look thin in tiles; try filled symbols or custom 3D-ish icons
- [ ] Test frame rate on a real device (Instruments > Animation Hitches)
- [ ] More life: butterflies, sun, occasional surprise animal; scene per time of day
- [ ] Motion inside sessions (breathing ball wobble) and tab-switch transitions
- [ ] Bring SceneScreen/icon tiles to Insights, Unload, Settings
- [ ] Check Calm, session, Insights, Settings screens and dark mode by eye
- [ ] Maybe a gentle wobble/squash on the breathing ball; custom clay illustrations later

## Background knowledge
- Clay = fill + inner white highlight (top-left) + inner dark dent (bottom-right) + soft drop shadow (ClaySurface, uses iOS 16+ `ShapeStyle.shadow(.inner)`).
- Canvas/surface colors are dynamic (warm cocoa in dark mode) via UIColor provider in Theme.
- Panic surfaces stay lavender, never red.

## Resources
- files: apps/ios/Ebb/DesignSystem/{Theme,ClaySurface,ClayCanvas,SquishyButtonStyle}.swift, App/RootView.swift, card/hero/intensity/helped views, BreathingCircle
- screenshot: scratchpad clay.png (not kept)

## Session log
### 2026-11-10 14:23 PST → 2026-11-10 14:25 PST
- Secret meadow (Snapchat-style pull-down): SceneScreen tracks overscroll via onGeometryChange(.scrollView minY) and overlays SecretMeadow (440pt) above the scene. Pieces pop up with a spring + light haptic as the pull uncovers them: Panda, Penguin (new), Flamingo, Elephant, Giraffe, Lion; the deepest pull shows HotAirBalloon + "You found the secret meadow 🌼". New Theme.hillMeadow. Removed .refreshable from Calm/Reflect (its spinner would cover the meadow; data still loads on appear).
- App-wide swipe: AppPage model orders Quick ⇄ Guided ⇄ Reflect ⇄ Settings; RootView owns tab + calmMode and a single simultaneous DragGesture (>60pt, mostly horizontal) with selection haptic. HomeView takes a mode binding and follows it with the direction-safe select(); removed its own grid swipe so the gestures don't fight.
- Verified: build; installed on sim and iPhone. Not verified by hand: meadow reveal look/feel, swipe navigation feel, tab change has no slide animation (native TabView).

### 2026-11-10 14:20 PST → 2026-11-10 14:22 PST
- App icon: .claude/resources/tools/make-icon.swift renders a 1024px clay seedling (teal leaves, pink bud) on grainy sky + hills with the sun, using Theme's light palette. Run: `swift .claude/resources/tools/make-icon.swift apps/ios/Ebb/Assets.xcassets/AppIcon.appiconset/AppIcon.png`. New Assets.xcassets; project.yml sets ASSETCATALOG_COMPILER_APPICON_NAME.
- Keyboard: KeyboardDismisser adds one window tap recognizer (cancelsTouchesInView=false, ignores taps on text views) installed from RootView; SceneScreen uses scrollDismissesKeyboard(.interactively).
- Verified: build; installed on sim and on the iPhone. Not verified: the icon on the home screen and keyboard dismissal by hand.

### 2026-11-10 14:17 PST → 2026-11-10 14:20 PST
- Ran on the user's iPhone 14 Pro: xcodebuild -destination id=00008120-000E65911ED8C01E -allowProvisioningUpdates DEVELOPMENT_TEAM=F2DD8TWKAQ (personal team), then devicectl install/launch with device C9474976-5B3F-5744-9CDC-B395F6DDA5B5. First launch needed the user to trust the developer profile (done).
- Merged Insights + Unload into Reflect tab (SceneScreen, BrainDumpCard, HelpedCard with ClayBar, PatternRow). NextStepSuggester moved to Core/Services. Deleted GardenView (the scene replaces it). Tabs: Calm, Reflect, Settings.
- Gotcha: I temporarily removed the Calm tab to screenshot Reflect and the user saw that install. Restored; don't hack tab order for screenshots again.
- Verified: build, sim screenshots of Reflect and Calm. Pending: user asked to make the whole app swipeable between tabs.

### 2026-11-10 14:13 PST → 2026-11-10 14:13 PST
- Fixed backwards Quick/Guided slide: the leaving grid kept its stale transition edge. HomeView.select(_:) now sets `slideFrom` first, then switches mode on the next main-queue pass; asymmetric move+opacity transition. Picker taps and swipes both route through select.
- Verified: build. Not verified: by hand in the simulator.

### 2026-11-10 14:12 PST → 2026-11-10 14:12 PST
- ModePicker now follows the clay format: white `.clay()` track, and the sliding blob is a `.clay(teal/lavender)` lump with GrainOverlay (was a flat capsule on a flat tile).
- Verified: build + simulator screenshot (screen scrolled, picker visible, raised and grainy).

### 2026-11-10 14:11 PST → 2026-11-10 14:11 PST
- Swipe the Calm tab's option grid sideways to switch Quick/Guided (DragGesture as simultaneousGesture; must be >60pt and mostly horizontal so vertical scroll and tile taps still work). CalmMode.swiped(dx:) holds the mapping; grid pushes in from the swiped side.
- Verified: build succeeds. Not verified: the swipe feel by hand in the simulator.

### 2026-11-10 14:07 PST → 2026-11-10 14:11 PST
- Moved scene pieces into DesignSystem/Scene/. Added SunView, MoonView, TwinklingStar, Butterfly, Firefly, Giraffe, Lion, Elephant, SurpriseAnimal (random guest walks across every 18-35s; first after 4s). Theme landscape colors are now dynamic (night palette) + sun/moon/firefly colors. LandscapeBackdrop switches day/night on colorScheme.
- Merged the Reset and Calm tabs into one "Calm" tab (HomeView): PanicHeroCard, ModePicker (Quick/Guided sliding clay blob, CalmMode model), OptionTile 2-column grid, CalmProgressCard. Deleted CalmHomeView, CalmProgramRow, ResetRow, ResetHeroCard.
- Verified: build succeeds; simulator screenshots in light (sun, lion, butterflies, bunny) and dark (moon, stars, fireflies, giraffe) and of the merged tab.
- Not verified: Guided mode tab switch by hand, real-device frame rate, Reduce Motion pass.

### 2026-11-10 14:06 PST → 2026-11-10 14:06 PST
- User: hard to swipe/scroll without accidentally clicking buttons. Rewrote SquishyButtonStyle as a PrimitiveButtonStyle driven by onTapGesture (cancelled by scrolling); squish plays after the tap instead of on touch-down. Helper view in SquishyButton.swift.
- Verified: BUILD SUCCEEDED, installed. Not verified: touch feel by hand (no touch automation available).

### 2026-11-10 14:04 PST → 2026-11-10 14:05 PST
- User: motion felt 'chalky' (choppy). Cause: TimelineView redrew the whole Canvas (blur + grain) every frame. Rebuilt the scene as layered views animated only by transforms; grain and clouds rasterized once with drawingGroup.
- User asked for animals/birds/flowers: added FlyingBird (flapping, gliding), SwayingFlower x5, HoppingBunny drifting along the hill, DriftModifier shared by clouds/birds/bunny.
- Bug found+fixed: drawingGroup clipped cloud blur into hard rectangles; padded before blur.
- Verified: BUILD SUCCEEDED; screenshots show soft clouds, birds, flowers, bunny moving between frames. Not verified: real-device frame rate.

### 2026-11-10 14:01 PST → 2026-11-10 14:03 PST
- User asked for dynamic movement. Added: drifting clouds + swaying trees (TimelineView in LandscapeBackdrop), FloatingModifier (hero cards bob), PopInModifier (staggered spring entrance for rows), symbol bounce on ClayIconTile. All respect Reduce Motion.
- Verified: BUILD SUCCEEDED; screenshot shows hero offset changing. Not verified by eye: actual animation smoothness, battery cost of TimelineView.

### 2026-11-10 13:57 PST → 2026-11-10 13:59 PST
- User wants a Clay (clay.com) feel. Saved references to design-references/clay/ with README.
- Added GrainOverlay, LandscapeBackdrop, SceneScreen, ClayIconTile, SectionLabel; new palette in Theme.
- Home + Calm use SceneScreen; rows use icon tiles; heroes get grain.
- Verified: BUILD SUCCEEDED, Home screenshot. Not verified: Calm screen, dark mode.

### 2026-11-10 13:54 PST → 2026-11-10 13:55 PST
- Built the clay design system and applied it to cards, heroes, intensity buttons, the breathing ball and all tab screens.
- Verified: BUILD SUCCEEDED; Home screen screenshot in Simulator looks right.
- Not verified: the other screens and dark mode.

## Cloud seam + squish-away (14:26 – 14:28 PST)
- CloudBand replaces the fog between SecretMeadow and the scene; puffs scale-squash away (staggered, driven by pull) on snap-back. Reduce Motion: no squish.

## Profile tab (14:29 – 14:30 PST)
- Settings tab → Profile: header (name/bio/stats), friends (invite via share sheet), achievement grid; Settings behind gear.

## Pinned scene + under-meadow + rounded font (14:31 – 14:32 PST)
- Scene stays fixed on pull; panel slides down revealing SecretMeadow below. CloudBand removed. App-wide SF Rounded.
- Profile avatar: pick a clay animal (AvatarPicker sheet), finished 14:33 PST.
- Gaegu handwriting font via ClayFont; titles removed; scene pin moved to GeometryReader (same-pass offset, no shake). Finished 14:38 PST.
- Font → Grandstander (neater, bolder); titles back as ClayTitle. Finished 14:39 PST.
- Font → Fredoka (rounder). Finished 14:40 PST.
- Reverted font to Grandstander (user preferred it over Fredoka). 14:40 PST.
- Panic/guided progress bar fills continuously within each technique. 15:05 PST.
- 2026-11-10 15:08 Session back button (stage back), breathing pace setting (breathPace 1.0/1.3/1.6 on breathing steps), ResetStep.addsOn for 'Sip in a little more', Profile gear moved to overlay (nav bar hidden). Sim OK; phone not connected.
- 2026-11-10 15:12 Breathing pace slider 1-10 (breathRate, 8=standard); editable ScheduleItem lists for guard windows, planned nudges, medications (AppStorage JSON); 988 call + text links.
- 2026-11-10 15:15 Tab swipe locked (counted) while Settings/editor are open, so slider and swipe-to-delete don't switch tabs.
- 2026-11-10 15:16 Sideways drags (decided on first movement) disable vertical scroll until lift.
- 2026-11-10 15:17 ClayTitle moved to sit on meadow above panel, rides with panel.
- 2026-11-10 15:22 Mascot (MascotPeek, MascotTip, Tip model + selfCheck, AnimalFigure extracted), ? replay per screen, Settings pops when leaving Profile tab, slider-only swipe lock. Sim verified screenshot; phone installed but locked.
- 2026-11-10 15:24 Tips became dimmed spotlight coach marks (TipCoach via anchor preference) with full mascot drawing.
- 2026-11-10 15:25 Swipe tip spotlights option grid; tip bubble pops in with spring per tip.
- 2026-11-10 15:26 Tip mascot alternates sides per tip and loops a pose (MascotPose: hop, lean, wiggle, squish, spin; phaseAnimator, still under Reduce Motion).
- 2026-11-10 15:29 SceneScreen scrolls to top on return if away >2s (quick mis-swipes keep place).
