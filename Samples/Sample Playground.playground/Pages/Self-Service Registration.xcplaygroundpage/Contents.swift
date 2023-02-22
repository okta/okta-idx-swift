/*:
 [Previous](@previous)

 # Self-Service Registration

 The [Basic Sign In](Basic%20Sign%20In) example showed how to identify the user and supply a password. However, if self service registration is enabled in the application's policy settings, the additional remediation `.selectEnrollProfile` is made available to the user.

 The "Select Enroll Profile" represents a "Sign Up" link on the form. Proceeding through this remediation will return the `.enrollProfile` remediation, which allows the user to fill in their profile details.
 
 This example will walk through those options.
 
 - Note:
   The purpose of this example is to demonstrate how to use the API, though in a real-world application it should not make assumptions about the presence of these remediations, and should give the user options to perform different available operations.

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
/*:
 We'll also define the user's profile values to be sent in the registration form.
 
 - Note:
   Ideally the fields within the registration remediation would be dynamically displayed to the user, but for the purposes of this example, we'll hard-code the fields.
 */
let profile = ["email": "jane.doe@example.com",
               "firstName": "Jane",
               "lastName": "Doe"]
let password = "MySecretPassword"

/*:
 We'll also define an error type to represent the various errors we can expect to encounter.
 */
public enum LoginError: Error {
    case error(_ error: Error)
    case message(_ string: String)
    case missingProfile(field: String)
    case cannotProceed
    case unexpectedAuthenticator
    case unknown
}
/*:
 As in our previous examples, we'll wrap the call in a Task, to allow the Playground page to continue.
 */
Task {
    do {
/*:
 ## Receive the first response
 To start authentication, we need to get the first initial response. In this case, since we're registering the user, we're looking for a particular remediation.
 */
var response = try await flow.start()
/*:
 ## Selecting the Enroll Profile option
 We start registration by selecting the `.selectEnrollProfile` remediation.
 */
if let remediation = response.remediations[.selectEnrollProfile] {
    response = try await remediation.proceed()
}

//: Once we receive the `.enrollProfile` remediation, we populate its fields with the values supplied by the user. Then, when all the fields are filled, we proceed through the remediation.
if let remediation = response.remediations[.enrollProfile] {
    for field in remediation.form.fields {
        guard let name = field.name else { continue }
        if let value = profile[name] {
            field.value = value
        } else if field.isRequired {
            // A required profile field was not supplied
            throw LoginError.missingProfile(field: name)
        }
    }
    response = try await remediation.proceed()
}
/*:
 ## Choosing a password
 After submitting the user's profile information, the user is prompted to choose a password. This uses the `.enrollAuthenticator` remediation.
 
 - Note:
   Depending on the app's sign on policy, the user may be prompted to supply their password within the `.enrollProfile` remediation.
 */
if let remediation = response.remediations[.enrollAuthenticator],
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
/*:
 ## Retrieving a token
 Finally, if we've made it this far, we'll assume we have a successful response. At this point, we can exchange the this response with a token.
 
 - Note:
   For the purposes of this sample, we'll assume that no additional MFA authenticators require enrolment. If your app's policy is set to require more than one factor, this code will not work.
*/
guard response.isLoginSuccessful else {
    throw LoginError.cannotProceed
}

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

