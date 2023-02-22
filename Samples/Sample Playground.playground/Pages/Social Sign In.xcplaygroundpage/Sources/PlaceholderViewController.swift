import UIKit
import AuthenticationServices

public class PlaceholderViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
