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
    private let configuration: IDXClient.Configuration
    private weak var presentationContext: ASWebAuthenticationPresentationContextProviding?
    private var webAuthSession: ASWebAuthenticationSession?

    private var client: IDXClient?
    private var completion: ((Result<IDXClient.Token, LoginError>) -> Void)?
    
    public init(configuration: IDXClient.Configuration) {
        self.configuration = configuration
    }
    
    public func login(service: IDXClient.Remediation.SocialAuth.Service, from presentationContext: ASWebAuthenticationPresentationContextProviding? = nil, completion: @escaping (Result<IDXClient.Token, LoginError>) -> Void) {
        self.presentationContext = presentationContext
        self.completion = completion
        
        IDXClient.start(with: configuration) { (client, error) in
            guard let client = client else {
                self.finish(with: error)
                return
            }
            
            self.client = client
            client.resume { (response, error) in
                guard let response = response else {
                    self.finish(with: error)
                    return
                }
                
                guard let remediation = response.remediations.first(where: { remediation in
                    let socialRemediation = remediation as? IDXClient.Remediation.SocialAuth
                    return socialRemediation?.service == service
                }) as? IDXClient.Remediation.SocialAuth
                else {
                    self.finish(with: .cannotProceed)
                    return
                }
                
                DispatchQueue.main.async {
                    self.login(with: remediation)
                }
            }
        }
    }
    
    func login(with remediation: IDXClient.Remediation.SocialAuth) {
        guard let client = client,
              let scheme = URL(string: client.context.configuration.redirectUri)?.scheme
        else {
            finish(with: .cannotProceed)
            return
        }

        let session = ASWebAuthenticationSession(url: remediation.redirectUrl,
                                                 callbackURLScheme: scheme)
        { [weak self] (callbackURL, error) in
            guard error == nil,
                  let callbackURL = callbackURL,
                  let client = self?.client
            else {
                self?.finish(with: error)
                return
            }
            
            let result = client.redirectResult(for: callbackURL)
            
            switch result {
            case .authenticated:
                client.exchangeCode(redirect: callbackURL) { (token, error) in
                    guard let token = token else {
                        self?.finish(with: error)
                        return
                    }
                    self?.finish(with: token)
                }

            default:
                self?.finish(with: .cannotProceed)
            }
        }
        
        session.presentationContextProvider = presentationContext
        session.prefersEphemeralWebBrowserSession = true
        session.start()
        
        self.webAuthSession = session
    }
    
    public enum LoginError: Error {
        case error(_ error: Error)
        case message(_ string: String)
        case cannotProceed
        case unknown
    }
}

// Utility functions to help return responses to the caller.
extension SocialLogin {
    func finish(with error: Error?) {
        if let error = error {
            finish(with: .error(error))
        } else {
            finish(with: .unknown)
        }
    }
    
    func finish(with error: LoginError) {
        completion?(.failure(error))
        completion = nil
    }
    
    func finish(with token: IDXClient.Token) {
        completion?(.success(token))
        completion = nil
    }
}
