// Renders Ebb's app icon (1024x1024 PNG) in the clay style: grainy sky, sun, two rolling clay hills, a clay sprout.
// Usage: swift .claude/resources/tools/make-icon.swift apps/ios/Ebb/Assets.xcassets/AppIcon.appiconset/AppIcon.png
import SwiftUI
import AppKit

func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color { Color(red: r, green: g, blue: b) }
let skyTop = rgb(0.47, 0.76, 0.89), skyBottom = rgb(0.70, 0.88, 0.93)
let hillFar = rgb(0.36, 0.62, 0.55), hillNear = rgb(0.27, 0.55, 0.33)
let sun = rgb(1.0, 0.84, 0.40), leaf = rgb(0.23, 0.62, 0.58), pink = rgb(0.93, 0.45, 0.62)

/// Clay fill: solid color with a soft light highlight top-left and a soft dent bottom-right.
extension Shape {
    func clay(_ c: Color, _ r: CGFloat = 18) -> some View {
        fill(c.shadow(.inner(color: .white.opacity(0.5), radius: r, x: r * 0.6, y: r * 0.8))
              .shadow(.inner(color: .black.opacity(0.18), radius: r * 1.4, x: -r * 0.6, y: -r)))
    }
}

struct Hill: Shape {
    let base: CGFloat, crest: CGFloat, peakAt: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: -20, y: rect.height * base))
        p.addQuadCurve(to: CGPoint(x: rect.width + 20, y: rect.height * (base + 0.04)),
                       control: CGPoint(x: rect.width * peakAt, y: rect.height * (2 * crest - base)))
        p.addLine(to: CGPoint(x: rect.width + 20, y: rect.height + 20))
        p.addLine(to: CGPoint(x: -20, y: rect.height + 20))
        p.closeSubpath()
        return p
    }
}

struct Grain: View {
    var body: some View {
        Canvas { ctx, size in
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<9000 {
                let x = Double.random(in: 0...size.width, using: &rng), y = Double.random(in: 0...size.height, using: &rng)
                let light = Bool.random(using: &rng)
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.8, height: 1.8)),
                         with: .color(light ? .white.opacity(0.22) : .black.opacity(0.12)))
            }
        }
    }
}

struct Icon: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [skyTop, skyBottom], startPoint: .top, endPoint: .bottom)
            Circle().fill(.white.opacity(0.3)).frame(width: 330).offset(x: 250, y: -250)
            Circle().clay(sun, 22).frame(width: 220).offset(x: 250, y: -250)
            Hill(base: 0.66, crest: 0.52, peakAt: 0.25).clay(hillFar, 26)
            Hill(base: 0.84, crest: 0.70, peakAt: 0.75).clay(hillNear, 26)
            // Clay sprout: stem + two leaves, sitting on the near hill.
            ZStack {
                Capsule().clay(leaf, 10).frame(width: 46, height: 300).offset(y: 40)
                Ellipse().clay(leaf, 22).frame(width: 250, height: 130).rotationEffect(.degrees(32)).offset(x: -112, y: -170)
                Ellipse().clay(rgb(0.30, 0.70, 0.62), 22).frame(width: 270, height: 140).rotationEffect(.degrees(-32)).offset(x: 120, y: -180)
                Circle().clay(pink, 14).frame(width: 80).offset(x: 0, y: -125)   // little bud where the leaves meet
            }
            .shadow(color: .black.opacity(0.2), radius: 24, y: 18)
            .offset(y: 150)
            Grain()
        }
        .frame(width: 1024, height: 1024)
        .clipped()
    }
}

@MainActor func render() {
    let r = ImageRenderer(content: Icon()); r.scale = 1
    guard let cg = r.cgImage else { fatalError("render failed") }
    let rep = NSBitmapImageRep(cgImage: cg)
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("wrote", CommandLine.arguments[1])
}
MainActor.assumeIsolated { render() }
