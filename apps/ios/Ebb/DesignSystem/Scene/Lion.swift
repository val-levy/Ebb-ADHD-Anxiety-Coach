import SwiftUI

/// A clay lion with a big fluffy mane, drawn once. Faces right.
struct Lion: View {
    private let coat = Color(red: 0.95, green: 0.72, blue: 0.36)
    private let mane = Color(red: 0.80, green: 0.42, blue: 0.18)

    var body: some View {
        ZStack {
            ForEach([-14.0, -7, 6, 13], id: \.self) { x in
                Capsule().fill(coat).frame(width: 6, height: 14).offset(x: x, y: 10)            // legs
            }
            Capsule().fill(coat).frame(width: 3, height: 16).rotationEffect(.degrees(-50)).offset(x: -24, y: -6)  // tail
            Circle().fill(mane).frame(width: 6).offset(x: -30, y: -11)
            Ellipse().fill(coat).frame(width: 40, height: 20)                                    // body
            Circle().fill(mane).frame(width: 26).offset(x: 18, y: -10)                           // mane
            Circle().fill(coat).frame(width: 15).offset(x: 21, y: -9)                            // face
            Circle().fill(.black.opacity(0.7)).frame(width: 2.5).offset(x: 24, y: -11)           // eye
            Ellipse().fill(mane).frame(width: 4, height: 3).offset(x: 28, y: -6)                 // nose
        }
        .frame(width: 80, height: 60)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
