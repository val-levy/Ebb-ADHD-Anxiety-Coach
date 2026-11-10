import SwiftUI

/// A calm claymation-style scene: drifting clouds, rolling hills, swaying trees and flowers, and a surprise animal now and then.
/// Light mode is daytime (sun, birds, butterflies, bunny); dark mode is a moonlit night (moon, twinkling stars, fireflies).
/// Every moving piece is drawn once and only transformed (offset/rotate/scale), so motion stays smooth.
/// Positions are normalized (0...1) so it fits any screen. All motion stops under Reduce Motion.
struct LandscapeBackdrop: View {
    private let clouds: [(y: Double, w: Double, duration: Double, start: Double)] =
        [(0.1, 0.5, 70, 0.1), (0.24, 0.38, 95, 0.55), (0.04, 0.32, 120, 0.8)]
    private let birds: [(y: Double, size: Double, duration: Double, start: Double)] =
        [(0.2, 16, 26, 0.2), (0.24, 12, 26, 0.25), (0.14, 14, 34, 0.7)]
    private let trees: [(x: Double, y: Double, s: Double)] = [(0.08, 0.6, 0.8), (0.14, 0.56, 1), (0.82, 0.54, 1.1), (0.9, 0.58, 0.8)]
    private let flowers: [(x: Double, y: Double, color: Color)] =
        [(0.3, 0.78, Theme.clayPink), (0.36, 0.8, Theme.clayLavender), (0.6, 0.74, Theme.clayOrange),
         (0.66, 0.76, Theme.clayPink), (0.72, 0.73, Theme.clayButter)]

    private let butterflies: [(y: Double, color: Color, duration: Double, start: Double)] =
        [(0.66, Theme.clayPink, 48, 0.15), (0.6, Theme.clayButter, 60, 0.6)]
    private let stars: [(x: Double, y: Double, s: Double)] =
        [(0.05, 0.08, 2), (0.18, 0.2, 1.5), (0.3, 0.06, 2.5), (0.44, 0.16, 1.5), (0.55, 0.05, 2),
         (0.62, 0.28, 1.5), (0.7, 0.12, 2.5), (0.95, 0.22, 2), (0.12, 0.34, 1.5), (0.4, 0.32, 2)]
    private let fireflies: [(x: Double, y: Double)] = [(0.22, 0.7), (0.45, 0.62), (0.58, 0.82), (0.76, 0.66), (0.92, 0.78), (0.1, 0.86)]

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [Theme.skyTop, Theme.skyBottom], startPoint: .top, endPoint: .bottom)
                if scheme == .dark {
                    ForEach(stars.indices, id: \.self) { i in
                        TwinklingStar(size: stars[i].s, delay: Double(i) * 0.37).position(x: stars[i].x * w, y: stars[i].y * h)
                    }
                    MoonView(size: 34).position(x: 0.82 * w, y: 0.36 * h)
                } else {
                    SunView(size: 38).position(x: 0.82 * w, y: 0.36 * h)
                }
                ForEach(clouds.indices, id: \.self) { i in
                    let c = clouds[i]
                    DriftingCloud(width: c.w * w, duration: c.duration, start: c.start, skyWidth: w)
                        .offset(y: c.y * h)
                }
                if scheme == .light {
                    ForEach(birds.indices, id: \.self) { i in
                        let b = birds[i]
                        FlyingBird(size: b.size, flapDelay: Double(i) * 0.15)
                            .offset(x: -30, y: b.y * h)
                            .drift(distance: w + 60, duration: b.duration, start: b.start)
                    }
                }
                HillShape(base: 0.62, crest: 0.48, peakAt: 0.2).fill(Theme.hillFar)
                ForEach(trees.indices, id: \.self) { i in
                    let t = trees[i]
                    SwayingTree(height: 22 * t.s, delay: Double(i) * 0.4).position(x: t.x * w, y: t.y * h)
                }
                SurpriseAnimal(sceneWidth: w)
                    .offset(y: 0.72 * h - 70)
                HillShape(base: 0.8, crest: 0.66, peakAt: 0.75).fill(Theme.hillNear)
                ForEach(flowers.indices, id: \.self) { i in
                    let f = flowers[i]
                    SwayingFlower(petal: f.color, height: 18, delay: Double(i) * 0.3).position(x: f.x * w, y: f.y * h)
                }
                if scheme == .light {
                    ForEach(butterflies.indices, id: \.self) { i in
                        let b = butterflies[i]
                        Butterfly(color: b.color, delay: Double(i) * 0.4)
                            .offset(x: -20, y: b.y * h)
                            .drift(distance: w + 40, duration: b.duration, start: b.start)
                    }
                    HoppingBunny()
                        .offset(x: -40, y: 0.82 * h - 20)
                        .drift(distance: w + 80, duration: 40, start: 0.3)
                } else {
                    ForEach(fireflies.indices, id: \.self) { i in
                        Firefly(delay: Double(i) * 0.5).position(x: fireflies[i].x * w, y: fireflies[i].y * h)
                    }
                }
                GrainOverlay(opacity: 0.18)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
