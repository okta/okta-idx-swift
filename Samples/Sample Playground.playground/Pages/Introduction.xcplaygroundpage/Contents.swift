/*:
 # Table of Contents
 * [Basic Sign In with Username and Password](Basic%20Sign%20In)
 * [Social Sign In using an IDP](Social%20Sign%20In)
 * [Self-Service Registration](Self-Service%20Registration)

 # Overview
 
 This collection of Playgrounds intends to demonstrate a few workflows you can use to get started using OktaIdx.
 
 The [OktaIdx API documentation](https://okta.github.io/okta-idx-swift/development/oktaidx/documentation/oktaidx/) is available on Github, so we encourage you to find more information there.
 
 - Note:
   Due to peculiarities of Xcode Playgrounds, this page will follow some more simplistic options here.
   \
   \
   For a complete working example, please see the `Samples/Signin Samples/MultifactorLogin.swift` file. Our examples within this Playground follow an imperative workflow, making assumptions about the options and order of the remediations reterned.
   \
   \
   These examples will use Swift Concurrency `async` / `await`.
 
 OktaIdx follows a call/response model, where a `Response` contains information about the next steps (or "Remediations") a user may take to authenticate. These options may ask the user to identify themselves (e.g. enter a username), to challenge an authenticator (enter a password or SMS/Email verification code), to make a choice as to which authenticator they want to use, and many other steps. These remediations contain form fields that are used to prompt the user for required information. Additionally, authenticators may be associated with a remediation or a particular field, which provides additional details about the actions a user can take.
 
 To continue, please [proceed to the next page](@next).
 */
