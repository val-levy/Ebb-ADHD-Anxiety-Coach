import SwiftUI

/// A round clay elephant with a curled trunk, drawn once. Faces right.
struct Elephant: View {
    private let skin = Color(red: 0.68, green: 0.70, blue: 0.80)
    private let ear = Color(red: 0.88, green: 0.66, blue: 0.74)

    var body: some View {
        ZStack {
            ForEach([-13.0, -5, 7, 14], id: \.self) { x in
                Capsule().fill(skin).frame(width: 8, height: 16).offset(x: x, y: 12)            // legs
            }
            Ellipse().fill(skin).frame(width: 42, height: 28)                                    // body
            Circle().fill(skin).frame(width: 22).offset(x: 20, y: -8)                            // head
            Ellipse().fill(ear).frame(width: 11, height: 15).offset(x: 14, y: -8)                // ear
            Capsule().fill(skin).frame(width: 6, height: 18).rotationEffect(.degrees(-20)).offset(x: 32, y: 4)    // trunk
            Circle().fill(.black.opacity(0.7)).frame(width: 2.5).offset(x: 25, y: -12)           // eye
        }
        .frame(width: 80, height: 64)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
