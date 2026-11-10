import SwiftUI

/// A clay giraffe, drawn once (flattened with drawingGroup). Faces right.
struct Giraffe: View {
    private let coat = Color(red: 0.96, green: 0.76, blue: 0.38)
    private let spot = Color(red: 0.72, green: 0.45, blue: 0.22)

    var body: some View {
        ZStack {
            ForEach([-12.0, -5, 7, 14], id: \.self) { x in
                Capsule().fill(coat).frame(width: 5, height: 22).offset(x: x, y: 12)          // legs
            }
            Ellipse().fill(coat).frame(width: 38, height: 20)                                    // body
            Capsule().fill(coat).frame(width: 9, height: 40).rotationEffect(.degrees(18)).offset(x: 17, y: -24)   // neck
            Ellipse().fill(coat).frame(width: 18, height: 11).rotationEffect(.degrees(15)).offset(x: 26, y: -44) // head
            Capsule().fill(spot).frame(width: 2.5, height: 7).offset(x: 21, y: -52)              // ossicones
            Capsule().fill(spot).frame(width: 2.5, height: 7).offset(x: 25, y: -53)
            ForEach([(-8.0, -3.0), (3, 3), (10, -4), (-2, 5), (18, -18), (20, -30)], id: \.0) { p in
                Circle().fill(spot).frame(width: 5).offset(x: p.0, y: p.1)                       // spots
            }
            Circle().fill(.black.opacity(0.7)).frame(width: 2.5).offset(x: 29, y: -46)           // eye
        }
        .frame(width: 80, height: 110)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
