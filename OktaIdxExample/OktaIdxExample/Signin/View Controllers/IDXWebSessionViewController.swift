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

import UIKit
import OktaIdx
import AuthenticationServices

final class IDXWebSessionViewController: UIViewController, IDXWebSessionController {
    var signin: Signin?
    var response: IDXClient.Response?
    var redirectUrl: URL?
    
    private var webAuthSession: ASWebAuthenticationSession?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let signin = self.signin,
              let remediation = response?.remediations[.redirectIdp] as? IDXClient.Remediation.SocialAuth,
              let idx = signin.idx,
              let scheme = URL(string: idx.context.configuration.redirectUri)?.scheme else
        {
            return
        }
        
        self.webAuthSession = ASWebAuthenticationSession(url: remediation.redirectUrl, callbackURLScheme: scheme) { (callbackURL, error) in
            guard error == nil, let callbackURL = callbackURL else {
                return
            }
            
            let result = signin.idx?.redirectResult(for: callbackURL)
            
            switch result {
            case .authenticated:
                idx.exchangeCode(redirect: callbackURL) { (token, error) in
                    if let error = error {
                        signin.failure(with: error)
                    } else if let token = token {
                        signin.success(with: token)
                    }
                }
                
            case .remediationRequired:
                idx.resume { (response, error) in
                    if let error = error {
                        signin.failure(with: error)
                    } else if let response = response {
                        signin.proceed(to: response)
                    }
                }
            case .invalidContext, .invalidRedirectUrl, .none:
                return
            }
        }
        
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        webAuthSession?.start()
    }
}

extension IDXWebSessionViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window ?? UIWindow()
    }
}
