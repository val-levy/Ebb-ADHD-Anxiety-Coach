import UIKit

/// Tap anywhere outside a text field to put the keyboard away.
/// One window-level tap recognizer that never cancels other touches, so buttons and scrolling still work,
/// and ignores taps on text inputs themselves, so tapping into a field still edits it.
final class KeyboardDismisser: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismisser()

    func install() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first,
              !(window.gestureRecognizers ?? []).contains(where: { $0.delegate === self }) else { return }
        let tap = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
    }

    func gestureRecognizer(_ g: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextView || touch.view is UITextField)
    }

    func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
}
