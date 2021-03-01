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
              let authURL = response?.remediation?.remediationOptions.first?.href,
              let scheme = URL(string: signin.idx.configuration.redirectUri)?.scheme else {
            return
        }
        
        self.webAuthSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { [unowned self] (callbackURL, error) in
            guard error == nil, let callbackURL = callbackURL else {
                return
            }
            
            let result = self.signin?.idx.redirectResult(redirect: callbackURL)
            
            switch result {
            case .authenticated:
                self.signin?.idx.exchangeCode(redirect: callbackURL) { (token, error) in
                    if let error = error {
                        self.signin?.failure(with: error)
                    } else if let token = token {
                        self.signin?.success(with: token)
                    }
                }
                
            case .remediationRequired:
                self.signin?.idx.introspect { (response, error) in
                    if let error = error {
                        self.signin?.failure(with: error)
                    } else if let response = response {
                        self.signin?.proceed(to: response)
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
