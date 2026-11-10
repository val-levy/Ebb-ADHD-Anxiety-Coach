import SwiftUI

/// A little clay penguin with a waving flipper look, drawn once.
struct Penguin: View {
    private let ink = Color(red: 0.16, green: 0.20, blue: 0.30)
    private let beak = Color(red: 0.98, green: 0.65, blue: 0.25)

    var body: some View {
        ZStack {
            Ellipse().fill(beak).frame(width: 10, height: 5).offset(x: -6, y: 22)                // feet
            Ellipse().fill(beak).frame(width: 10, height: 5).offset(x: 6, y: 22)
            Ellipse().fill(ink).frame(width: 30, height: 42)                                      // body
            Ellipse().fill(.white).frame(width: 20, height: 30).offset(y: 5)                      // belly
            Capsule().fill(ink).frame(width: 7, height: 18).rotationEffect(.degrees(-35)).offset(x: 17, y: -2)  // flipper
            Circle().fill(.white).frame(width: 6).offset(x: -5, y: -11)                           // eyes
            Circle().fill(.white).frame(width: 6).offset(x: 5, y: -11)
            Circle().fill(.black).frame(width: 3).offset(x: -5, y: -11)
            Circle().fill(.black).frame(width: 3).offset(x: 5, y: -11)
            Triangle().fill(beak).frame(width: 8, height: 6).rotationEffect(.degrees(180)).offset(y: -5)
        }
        .frame(width: 50, height: 54)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
