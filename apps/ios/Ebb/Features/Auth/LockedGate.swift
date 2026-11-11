import SwiftUI

/// Shows content but catches taps until signed in. Taps only, so tab swipes still pass through.
struct LockedGate: ViewModifier {
    let reason: String
    @EnvironmentObject private var session: SessionStore

    func body(content: Content) -> some View {
        content.overlay {
            if !session.isSignedIn {
                Color.clear.contentShape(.rect).onTapGesture { _ = session.requireSignIn(reason: reason) }
            }
        }
    }
}

extension View {
    func lockedUntilSignIn(_ reason: String) -> some View { modifier(LockedGate(reason: reason)) }
}
