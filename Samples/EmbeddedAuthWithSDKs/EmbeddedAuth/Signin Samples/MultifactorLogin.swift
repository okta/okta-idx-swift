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

import Foundation
import OktaIdx

public class MultifactorLogin {
    let configuration: IDXClient.Configuration
    let username: String
    let password: String?
    let stepHandler: (Step) -> Void
    
    var client: IDXClient?
    var response: IDXClient.Response?
    var completion: ((Result<IDXClient.Token, LoginError>) -> Void)?
    
    public init(configuration: IDXClient.Configuration, username: String, password: String?, stepHandler: @escaping (Step) -> Void) {
        self.configuration = configuration
        self.username = username
        self.password = password
        self.stepHandler = stepHandler
    }
    
    public func login(completion: @escaping (Result<IDXClient.Token, LoginError>) -> Void) {
        self.completion = completion
        
        IDXClient.start(with: configuration) { (client, error) in
            guard let client = client else {
                self.finish(with: error)
                return
            }
            
            self.client = client
            client.delegate = self
            client.resume(completion: nil)
        }
    }
    
    public func select(factor: IDXClient.Authenticator.Kind) {
        guard let remediation = response?.remediations[.selectAuthenticatorAuthenticate],
              let authenticatorsField = remediation["authenticator"],
              let factorField = authenticatorsField.options?.first(where: { field in
                field.authenticator?.type == factor
              })
        else {
            finish(with: .cannotProceed)
            return
        }
        
        authenticatorsField.selectedOption = factorField
        remediation.proceed(completion: nil)
    }

    public func verify(code: String) {
        guard let remediation = response?.remediations[.challengeAuthenticator] else {
            finish(with: .cannotProceed)
            return
        }
        
        remediation.credentials?.passcode?.value = code
        remediation.proceed(completion: nil)
    }
    
    public enum Step {
        case chooseFactor(_ factors: [IDXClient.Authenticator.Kind])
        case verifyCode(factor: IDXClient.Authenticator.Kind)
    }
    
    public enum LoginError: Error {
        case error(_ error: Error)
        case message(_ string: String)
        case cannotProceed
        case unexpectedAuthenticator
        case unknown
    }
}

extension MultifactorLogin: IDXClientDelegate {
    public func idx(client: IDXClient, didReceive error: Error) {
        finish(with: error)
    }
    
    public func idx(client: IDXClient, didReceive token: IDXClient.Token) {
        finish(with: token)
    }
    
    public func idx(client: IDXClient, didReceive response: IDXClient.Response) {
        self.response = response
        
        // If a response is successful, immediately exchange it for a token.
        guard !response.isLoginSuccessful else {
            response.exchangeCode(completion: nil)
            return
        }
        
        // If no remediations are present, abort the login process.
        guard let remediation = response.remediations.first else {
            finish(with: .cannotProceed)
            return
        }
        
        // If any error messages are returned, report them and abort the process.
        if let message = response.messages.allMessages.first {
            finish(with: .message(message.message))
            return
        }
        
        // Handle the various remediation choices the client may be presented with within this policy.
        switch remediation.type {
        case .identify:
            remediation.identifier?.value = username
            remediation.credentials?.passcode?.value = password
            remediation.proceed(completion: nil)
                        
        // The challenge authenticator remediation is used to request a passcode of some sort from the user, either the user's password, or an authenticator verification code.
        case .challengeAuthenticator:
            guard let authenticator = remediation.authenticators.first else {
                finish(with: .unexpectedAuthenticator)
                return
            }
            
            switch authenticator.type {
            
            // We may be requested to supply a password on a separate remediation step, for example if the user can authenticate using a factor other than password. In this case, if we have a password, we can immediately supply it.
            case .password:
                if let password = password {
                    remediation.credentials?.passcode?.value = password
                    remediation.proceed(completion: nil)
                } else {
                    finish(with: .unexpectedAuthenticator)
                }

            default:
                stepHandler(.verifyCode(factor: authenticator.type))
            }
                        
        case .selectAuthenticatorAuthenticate:
            let factors: [IDXClient.Authenticator.Kind]
            factors = remediation["authenticator"]?
                .options?.compactMap({ field in
                    field.authenticator?.type
                }) ?? []
            
            // If a password is supplied, immediately select the password factor if it's given as a choice.
            if factors.contains(.password) && password != nil {
                select(factor: .password)
            } else {
                stepHandler(.chooseFactor(factors))
            }
            
        default:
            finish(with: .cannotProceed)
        }
    }
}

// Utility functions to help return responses to the caller.
extension MultifactorLogin {
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
