/*
 * Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import AuthenticationServices
import Foundation
import OktaIdx

extension OktaIdxAuth.Implementation.Request {
    @available(iOSApplicationExtension 12.0, *)
    class SocialAuthenticate: Request<Response>, OktaIdxAuthRemediationRequest {
        private var webAuthSession: ASWebAuthenticationSession?
        
        private var canStartSession: Bool {
            if #available(iOSApplicationExtension 13.4, *) {
                return webAuthSession?.canStart == true
            }
            
            return true
        }
        
        final func send(to implementation: OktaIdxAuth.Implementation, from response: IDXClient.Response) {
            guard let authURL = response.remediation?[.redirectIdp]?.href,
                  let scheme = URL(string: implementation.client.configuration.redirectUri)?.scheme else
            {
                return
            }
            
            self.webAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { (callbackURL, error) in
                guard error == nil, let
                        callbackURL = callbackURL else
                {
                    return
                }
                
                let result = implementation.client.redirectResult(redirect: callbackURL)
                
                switch result {
                case .authenticated:
                    implementation.client.exchangeCode(redirect: callbackURL) { (token, error) in
                        if let error = error {
                            implementation.fail(with: error)
                            
                            self.completion?(nil, error)
                        } else if let token = token {
                            implementation.delegate?.didSucceed(with: token)
                            
                            self.completion?(T(status: .success,
                                               token: token,
                                               context: nil,
                                               additionalInfo: nil),
                                             nil)
                        }
                    }
                    
                case .remediationRequired:
                    implementation.client.introspect { (response, error) in
                        if let error = error {
                            implementation.fail(with: error)
                            
                            self.completion?(nil, error)
                        } else if let response = response {
                            // TODO: Handle remediation response here.
                            self.needsAdditionalRemediation(using: response, from: implementation)
                        }
                    }
                case .invalidContext, .invalidRedirectUrl:
                    self.fatalError(AuthError.internalError(message: "Unexpected RedirectResult: \(result). Check correctness of redirect URL and state."))
                }
            }
            
            guard let webAuthSession = webAuthSession, canStartSession else {
                self.fatalError(AuthError.internalError(message: "Cannot start session. Check presentation context availability."))
                return
            }
            
            prepareWebSession(webAuthSession)
            
            webAuthSession.start()
        }
        
        func prepareWebSession(_ session: ASWebAuthenticationSession) {
            // Can be overriden to prepare ASWebAuthenticationSession object.
            // Template method
        }
    }
    
    @available(iOSApplicationExtension 13.0, *)
    class SocialAuthenticateIOS13: SocialAuthenticate {
        private var webAuthSession: ASWebAuthenticationSession?
        private let options: OktaIdxAuth.SocialOptions
        
        init(options: OktaIdxAuth.SocialOptions, completion: OktaIdxAuth.ResponseResult<Response>?) {
            self.options = options
            
            super.init(completion: completion)
        }
        
        override func prepareWebSession(_ session: ASWebAuthenticationSession) {
            session.presentationContextProvider = options.presentationContext
            session.prefersEphemeralWebBrowserSession = options.prefersEphemeralSession
        }
    }
}
