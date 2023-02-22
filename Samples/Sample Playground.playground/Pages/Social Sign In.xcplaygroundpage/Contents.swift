/*:
 [Previous](@previous)

 # Social Sign In using an IDP

 Authenticating using a social IDP is fairly straightforward. This playground page will show how to dig into the additional capabilities each remediation optionally supports.

 [Authenticators](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/authenticator) and [Remediations](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/remediation) have varying types of capabilities they offer. For example, a Phone authenticator may be capable of sending, or resending, a verification code. Email authenticators may be able to poll in the background while waiting for a user to click the verification link in their email.
 
 Whichever the option, these operations are described as a [Capability](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/capability). This sample therefore uses the [SocialIDP](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/capability/socialidp) capability, which exposes details about the IDP vendor, particularly the URL needed to be redirected to in order to authenticate.
 
 With that out of the way, lets try our sample code. To start, we'll get some Playgrounds housekeeping out of the way.
 */
import UIKit
import AuthenticationServices
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: We'll also create a view controller to not only show the simulator within the playground, but also to define the presentation context for the authorization web view controller.
let placeholderController = PlaceholderViewController()
PlaygroundPage.current.liveView = placeholderController
/*:
 ## Configure the authentication flow
 We'll start by creating an instance of the [InteractionCodeFlow](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/interactioncodeflow) class, which will be used to interact with Okta to perform the sign in operation.
 
 Update the placeholder values below with the settings in your Okta Admin dashboard.
 */
import OktaIdx
let flow = InteractionCodeFlow(issuer: URL(string: "https://<#domain#>/oauth2/default")!,
                               clientId: "<#client_id#>",
                               scopes: "openid profile offline_access",
                               redirectUri: URL(string: "<#redirect_uri#>")!)
//: We also want to pull out the application's redirect scheme, since this is needed by the AuthenticationServices framework.
guard let scheme = flow.redirectUri.scheme else {
    throw LoginError.cannotProceed
}
/*:
 We'll also define an error type to represent the various errors we can expect to encounter.
 */
public enum LoginError: Error {
    case error(_ error: Error)
    case message(_ string: String)
    case cannotProceed
    case unexpectedAuthenticator
    case unknown
}

/*:
 Since the login function is asynchronous, we'll wrap the call in a Task, to allow the Playground page to continue. Your implementation may vary.
 */
Task {
    do {
/*:
 ## Find the Social IDP capability
 To start authentication, we need to get the first initial response. This usually is a prompt to input the user's identifier (username), or to sign in using one of several Social IDPs.
 */
let response = try await flow.start()

//: We then dig through the remediations, finding the remediation that matches the Social IDP we're interested in, and pulling out its capability object for later use.
guard let remediation = response.remediations.first(where: { $0.socialIdp?.service == .facebook }),
      let capability = remediation.socialIdp
else {
    throw LoginError.cannotProceed
}
/*:
 ## Presenting the Social IDP web URL
 Signing in with an IDP functions similarly to standard OIDC sign in flows. We need to present the [redirectUrl](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/capability/socialidp/redirecturl) to the user using an instance of `ASWebAuthenticationSession`. When the browser redirects to our own client application's scheme, we can then exchange that callback URL with Okta tokens.
 */
let callbackUrl: URL = try await withCheckedThrowingContinuation { continuation in
    // Create an ASWebAuthenticationSession to trigger the IDP OAuth2 flow.
    let session = ASWebAuthenticationSession(url: capability.redirectUrl,
                                             callbackURLScheme: scheme)
    { (callbackURL, error) in
        // Ensure no error occurred, and that the callback URL is valid.
        guard error == nil,
              let callbackURL = callbackURL
        else {
            continuation.resume(throwing: error ?? LoginError.cannotProceed)
            return
        }
        
        continuation.resume(returning: callbackURL)
    }
    
    // Start and present the web authentication session.
    session.presentationContextProvider = placeholderController
    session.prefersEphemeralWebBrowserSession = true
    session.start()
}
/*:
 We then inspect the result of the callback URL. The [RedirectResult](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/interactioncodeflow/redirectresult) is used to determine what the result of the sign in was.
 
 When the social login result is `authenticated`, use the flow to exchange the callback URL returned from ASWebAuthenticationSession with an Okta token.
*/
switch flow.redirectResult(for: callbackUrl) {
case .authenticated:
    let token = try await flow.exchangeCode(redirect: callbackUrl)
    print("Received token \(token.accessToken)")

default:
    throw LoginError.cannotProceed
}
/*:
## Wrapping up
At this point we can wrap up the Playground page to catch and report errors, and to finish the current page's execution.
*/
    } catch {
        print(error)
    }
    PlaygroundPage.current.finishExecution()
}
/*:
 Now that we've demonstrated how to use Social Login, we can move onto a more complicated example in [next page](@next).
 */
