
# Okta OIE / IDX Migration Guide

## Migrating from `okta-auth-swift`

### Configuring and initializing your client

```swift
let config = IDXClient.Configuration(
    issuer: "https://{yourOktaDomain}/oauth2/default",
    clientId: "clientId",
    clientSecret: nil,
    scopes: ["openid", "email", "offline_access"],
    redirectUri: "com.myapp:/redirect/uri")
    
IDXClient.start(configuration: config) { result in
    switch result {
    case .failure(let error):
        // Handle the error
    case .success(let client):
        // Proceed to the next step
        client.resume() { result in
            // Handle the result
        }
    }
}
```

### Authenticate a user 

```swift
if let identify = response.remediations.identify {
    identify.authenticate(username: "user@example.com", password: "secret") { result in
        // Handle the result
    } 
}
```

### Forgot password

```swift
if let authenticator = response.authenticators.current as? Recoverable,
    authenticator.canRecover
{
    authenticator.recover() { result in 
        guard case let .success(response) = result,
            let selectAuthenticator = response.remediations.selectAuthenticatorAuthenticate
        else {
            // Handle error
            return
        }
        
        // Choose the appropriate factor
        selectAuthenticator.choose(authenticator: .email) { result in
            // Handle the response
        }
    }
}
```

### Responding to events

OktaIdx supports the use of a delegate to centralize response handling and processing.

```swift
class LoginManager: IDXClientDelegate {
    private var client: IDXClient?
    let username: String
    let password: String
    
    func start() {
        IDXClient.start(configuration: config) { result in
            switch result {
            case .failure(let error):
                // Handle the error
            case .success(let client):
                self.client = client
                client.delegate = self
                client.resume()
            }
        }
    }
    
    func idx(client: IDXClient, didReceive response: IDXClient.Response) {
        // If login is successful, immediately exchange it for a token.
        guard !response.isLoginSuccessful else {
            response.exchangeCode()
            return
        }
        
        // Identify the user
        if let remediation = response.remediations.identify {
            remediation.authenticate(username: username, password: password)
        }
        
        // Select the MFA authenticator to use
        else if let remediation = response.remediations.selectAuthenticatorAuthenticate {
            remediation.choose(option: remediation.options[.email])
        }
        
        // Supply the authenticator verification code
        else if let remediation = response.remediations.challengeAuthenticator {
            remediation.verify(passcode: "passcode")
        }
    }

    func idx(client: IDXClient, didReceive token: IDXClient.Token) {
        // Login succeeded, with the given token.
    }

    func idx(client: IDXClient, didReceive error: Error) {
        // Handle the error
    }
}
```
