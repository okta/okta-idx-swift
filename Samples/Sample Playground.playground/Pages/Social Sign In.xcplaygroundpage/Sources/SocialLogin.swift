//
// Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
// The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and limitations under the License.
//

import UIKit
import OktaIdx
import AuthenticationServices

/// This class demonstrates how implementing signin with social auth providers can be implemented.
///
/// The completion handler supplied to the `login` function will be invoked once, either with a fatal error, or with a token.
///
/// Example:
///
/// ```swift
/// self.authHandler = SocialLogin(configuration: configuration)
/// self.authHandler?.login(service: .facebook)
/// { result in
///     switch result {
///     case .success(let token):
///         print(token)
///     case .failure(let error):
///         print(error)
///     }
/// }
/// ```
///
/// If you want to use a custom presentation context, you can optionally supply it to the login method.
public class SocialLogin {
    private let flow: InteractionCodeFlow

    public init(issuer: URL,
                clientId: String,
                scopes: String,
                redirectUri: URL)
    {
        // Initializes the flow which can be used later in the process.
        flow = InteractionCodeFlow(issuer: issuer,
                                   clientId: clientId,
                                   scopes: scopes,
                                   redirectUri: redirectUri)
    }

    /// Public function used to initiate login using a given Social Authentication service.
    ///
    /// Optionally, a presentation context can be supplied when presenting the ASWebAuthenticationSession instance.
    /// - Parameters:
    ///   - service: Social service to authenticate against.
    ///   - presentationContext: Optional presentation context to present login from.
    public func login(service: Capability.SocialIDP.Service,
                      from presentationContext: ASWebAuthenticationPresentationContextProviding? = nil) async throws -> Token
    {
        let response = try await flow.start()

        // Find the Social IDP remediation that matches the requested social auth service.
        guard let remediation = response.remediations.first(where: { $0.socialIdp?.service == service }),
              let capability = remediation.socialIdp
        else {
            throw LoginError.cannotProceed
        }
        
        // Present the user with a web sign in form for the social provider,
        // and receive the subsequent redirect URL.
        let callbackUrl = try await login(with: capability)

        // Inspect the redirect URL to deterine what the result was.
        switch flow.redirectResult(for: callbackUrl) {
        case .authenticated:
            // When the social login result is `authenticated`, use the
            // flow to exchange the callback URL returned from
            // ASWebAuthenticationSession with an Okta token.
            return try await flow.exchangeCode(redirect: callbackUrl)

        default:
            throw LoginError.cannotProceed
        }
    }

    @MainActor
    func login(with idp: Capability.SocialIDP,
               from presentationContext: ASWebAuthenticationPresentationContextProviding? = nil) async throws -> URL {
        // Retrieve the Redirect URL scheme from our configuration, to
        // supply it to the ASWebAuthenticationSession instance.
        guard let scheme = flow.redirectUri.scheme else {
            throw LoginError.cannotProceed
        }

        return try await withCheckedThrowingContinuation { continuation in
            // Create an ASWebAuthenticationSession to trigger the IDP OAuth2 flow.
            let session = ASWebAuthenticationSession(url: idp.redirectUrl,
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
            session.presentationContextProvider = presentationContext
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    public enum LoginError: Error {
        case error(_ error: Error)
        case message(_ string: String)
        case cannotProceed
        case unknown
    }
}
