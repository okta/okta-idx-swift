/*:
 [Previous](@previous)

 # Basic Sign In with Username and Password

 To introduce you to the basics of authenticating using OktaIdx, we'll start with a simple username / password flow. This will allow us to introduce a few key concepts, while keeping the code simple.
 
 - Note:
   Simple username and password authentication doesn't need the full power of OktaIdx, but it is a useful way to demonstrate a simple flow.
   \
   \
   If you do not intend to implement MFA functionality, you can use the [Resource Owner Flow](https://okta.github.io/okta-mobile-swift/development/oktaoauth2/documentation/oktaoauth2/resourceownerflow) within the [okta-mobile-swift](https://github.com/okta/okta-mobile-swift) SDK.
 
 This workflow will demonstrate filling out two separate remediations (`.identify`, and `.challengeAuthenticator`), and finally exchanging a successful response for a token.
 
 With that out of the way, lets try our sample code. To start, we'll get some Playgrounds housekeeping out of the way.
 */
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
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
let username = "<#username#>"
let password = "<#password#>"

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
 ## Step through each response in the flow
 To start authentication, we need to get the first initial response. This usually is a prompt to input the user's identifier (username), and depending on policy settings, may also include a field for the user's password.
 
 We plan to step through multiple responses, so we're making this a `var` variable.
 */
var response = try await flow.start()
//: At this point, we loop over each form response, until we successfully sign in.
while !response.isLoginSuccessful {
//: We'll start checking each response at the beginning to see if any error messages are returned, report them and abort the process.  Under normal circumstances we might want to present these errors to the user, since some messages are actionable by the user.
    if let message = response.messages.allMessages.first {
        throw LoginError.message(message.message)
    }
/*:
 We then try to find the remediation asking for the user's identifier, and supply the user's username to the appropriate field.
 
 Sometimes the form allows the password to be supplied in the same remediation, so we should also try to pass that along to the passcode field.
 
 With those values filled out, we can call [proceed](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/remediation/proceed()) to submit the form, proceeding to the next response in the flow.
 */
    if let remediation = response.remediations[.identify],
       let usernameField = remediation["identifier"]
    {
        usernameField.value = username
        remediation["credentials.passcode"]?.value = password
        response = try await remediation.proceed()
    }
//: If the current form doesn't have the `identifier` remediation, we'll try to find the password authenticator challenge remediation, which is used to supply the user's password.
    else if let remediation = response.remediations[.challengeAuthenticator],
            let passwordField = remediation["credentials.passcode"]
    {
//: We'll check to make sure the user is being prompted to challenge the "password" authenticator, since this may instead be prompting to challenge some other authenticator method (e.g. email, phone, security question, etc).
        guard remediation.authenticators.contains(where: { $0.type == .password })
        else {
            throw LoginError.unexpectedAuthenticator
        }
//: Supply the user's password to the field and proceed through the remediation to receive the next form.
        passwordField.value = password
        response = try await remediation.proceed()
    }
//: Finally, we'll check to see if we have received a remediation we don't expect. This can be an extension point for your application, to support other stages in the authentication flow.
    else {
        throw LoginError.cannotProceed
    }
}
/*:
 ## Retrieving a token
Finally, if we've made it this far, we know we have a successful response. At this point, we can exchange the this response with a token.
 */
let token = try await response.exchangeCode()
//: Once we receive the token, we can either use its values directly, or we can store it for later use using the ``Credential`` class.
    print("Received token \(token.accessToken)")
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
 Now that we've demonstrated a simple sign in flow, lets move on to a more complicated example on the [next page](@next).
 */
