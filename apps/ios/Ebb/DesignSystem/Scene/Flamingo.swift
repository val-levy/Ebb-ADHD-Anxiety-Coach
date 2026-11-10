import SwiftUI

/// A pink clay flamingo standing on one leg, drawn once.
struct Flamingo: View {
    private let pink = Color(red: 0.97, green: 0.56, blue: 0.66)
    private let leg = Color(red: 0.88, green: 0.42, blue: 0.52)

    var body: some View {
        ZStack {
            Capsule().fill(leg).frame(width: 3, height: 30).offset(y: 18)                          // leg
            Capsule().fill(leg).frame(width: 3, height: 12).rotationEffect(.degrees(60)).offset(x: 4, y: 10)
            Ellipse().fill(pink).frame(width: 30, height: 18).offset(y: -2)                         // body
            Capsule().fill(pink).frame(width: 5, height: 28).rotationEffect(.degrees(15)).offset(x: 10, y: -20)  // neck
            Circle().fill(pink).frame(width: 10).offset(x: 13, y: -34)                               // head
            Capsule().fill(.black.opacity(0.75)).frame(width: 8, height: 3).rotationEffect(.degrees(35)).offset(x: 18, y: -31)
            Circle().fill(.black.opacity(0.7)).frame(width: 2).offset(x: 14, y: -36)
        }
        .frame(width: 50, height: 80)
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        .drawingGroup()
    }
}
