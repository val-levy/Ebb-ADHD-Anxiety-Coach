import SwiftUI

/// A round clay panda sitting down, drawn once.
struct Panda: View {
    private let fur = Color(red: 0.97, green: 0.96, blue: 0.93)
    private let ink = Color(red: 0.18, green: 0.18, blue: 0.20)

    var body: some View {
        ZStack {
            Ellipse().fill(fur).frame(width: 40, height: 34).offset(y: 10)                       // body
            Capsule().fill(ink).frame(width: 12, height: 18).rotationEffect(.degrees(30)).offset(x: -16, y: 10)
            Capsule().fill(ink).frame(width: 12, height: 18).rotationEffect(.degrees(-30)).offset(x: 16, y: 10)
            Circle().fill(ink).frame(width: 11).offset(x: -11, y: -22)                            // ears
            Circle().fill(ink).frame(width: 11).offset(x: 11, y: -22)
            Circle().fill(fur).frame(width: 30).offset(y: -12)                                    // head
            Ellipse().fill(ink).frame(width: 8, height: 10).rotationEffect(.degrees(-20)).offset(x: -6, y: -13)
            Ellipse().fill(ink).frame(width: 8, height: 10).rotationEffect(.degrees(20)).offset(x: 6, y: -13)
            Ellipse().fill(ink).frame(width: 5, height: 3.5).offset(y: -5)                        // nose
        }
        .frame(width: 60, height: 64)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
