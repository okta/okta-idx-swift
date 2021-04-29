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

protocol OktaIdxAuthImplementation {
    var delegate: OktaIdxAuthImplementationDelegate? { get set }
    
    func authenticate(username: String,
                      password: String?,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    @available(iOSApplicationExtension 13.0, *)
    func socialAuth(with options: OktaIdxAuth.SocialOptions,
                    completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    func socialAuth(completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func changePassword(_ password: String,
                        completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func verifyAuthenticator(code: String,
                             completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
}

protocol OktaIdxAuthImplementationDelegate: class {
    func didSucceed(with token: IDXClient.Token)
    func didFail(with error: Error)
}

protocol OktaIdxAuthRemediationRequest {
    func send(to implementation: OktaIdxAuth.Implementation,
              from response: IDXClient.Response)
}

extension OktaIdxAuth {
    class Implementation {
        let client: IDXClient
        var delegate: OktaIdxAuthImplementationDelegate?
        
        init(with client: IDXClient) {
            self.client = client
        }

        class Request<T> where T: Response {
            typealias Implementation = OktaIdxAuth.Implementation
            typealias Request = Implementation.Request
            typealias Response = OktaIdxAuth.Response
            typealias AuthError = OktaIdxAuth.Implementation.AuthError

            let completion: OktaIdxAuth.ResponseResult<T>?
            
            init(completion:OktaIdxAuth.ResponseResult<T>?) {
                self.completion = completion
            }
            
            func fatalError(_ error: Error) {
                completion?(nil, error)
            }
            
            func fatalError(_ error: AuthError) {
                completion?(nil, error)
            }
            
            func recoverableError(response: T, error: AuthError) {
                completion?(response, error)
            }
            
            func doesFieldHaveError(implementation: Implementation,
                                    from option: IDXClient.Remediation.Option,
                                    in field: IDXClient.Remediation.FormValue) -> (Response, AuthError)?
            {
                return nil
            }
            
            func needsAdditionalRemediation(using response: IDXClient.Response, from implementation: Implementation) {
                fatalError(.unexpectedTransitiveRequest)
            }
            
            func proceed(to implementation: OktaIdxAuth.Implementation,
                         using option: IDXClient.Remediation.Option,
                         with parameters: IDXClient.Remediation.Parameters? = nil)
            {
                guard let self = self as? Request<T> & OktaIdxAuthRemediationRequest else {
                    fatalError(.unexpectedTransitiveRequest)
                    return
                }

                option.proceed(with: parameters) { (response, error) in
                    guard let response = response else {
                        self.fatalError(.missingRemediation)
                        return
                    }
                    
                    if let error = error ?? AuthError(from: response) {
                        self.fatalError(error)
                        return
                    }

                    if response.isLoginSuccessful {
                        implementation.succeeded(with: response) { (token, error) in
                            guard let token = token else {
                                let error = error ?? AuthError.failedToExchangeToken
                                self.fatalError(error)
                                return
                            }
                            
                            self.completion?(T(status: .success,
                                               token: token,
                                               context: nil,
                                               additionalInfo: nil),
                                             nil)
                        }
                        return
                    }

                    self.send(to: implementation, from: response)
                }
            }
        }
    }
}

extension OktaIdxAuth.Implementation: OktaIdxAuthImplementation {
    enum AuthError: Error, LocalizedError {
        case missingResponse
        case missingRemediation
        case unexpectedTransitiveRequest
        case serverError(message: String)
        case failedToExchangeToken
        case internalError(message: String)

        init?(from response: IDXClient.Response) {
            guard let message = response.messages?.first else {
                return nil
            }
            
            self.init(from: message)
        }
        
        init?(from message: IDXClient.Message) {
            self = .serverError(message: message.message)
        }
        
        var errorDescription: String? {
            switch self {
            case .missingResponse:
                return "Missing a response"
            case .missingRemediation:
                return "Missing an expected remediation"
            case .unexpectedTransitiveRequest:
                return "An unexpected request was received"
            case .failedToExchangeToken:
                return "Authentication succeeded, but failed to exchange a token"
            case .serverError(message: let message):
                return message
            case .internalError(message: let message):
                return "An internal error occurred: \(message)"
            }
        }
    }
    
    func succeeded(with response: IDXClient.Response, completion: @escaping(IDXClient.Token?, Error?) -> Void) {
        guard let delegate = delegate else {
            fail(with: AuthError.internalError(message: "Missing implementation delegate"))
            return
        }
        
        response.exchangeCode { (token, error) in
            guard let token = token else {
                let error = error ?? AuthError.failedToExchangeToken
                self.fail(with: error)
                completion(nil, error)
                return
            }
            
            delegate.didSucceed(with: token)
            completion(token, error)
        }
    }
    
    func fail(with error: Error) {
        delegate?.didFail(with: error)
    }
    
    @objc
    func authenticate(username: String,
                      password: String? = nil,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        client.start { (context, response, error) in
            guard let response = response else {
                self.fail(with: AuthError.missingResponse)
                return
            }

            if let error = error ?? AuthError(from: response) {
                self.fail(with: error)
                return
            }
            
            let request = Request<OktaIdxAuth.Response>.Authenticate(username: username,
                                                                     password: password,
                                                                     completion: completion)
            request.send(to: self,
                         from: response)
        }
    }
    
    @available(iOSApplicationExtension 13.0, *)
    @objc func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        client.start { (context, response, error) in
            guard let response = response else {
                self.fail(with: AuthError.missingResponse)
                return
            }

            if let error = error ?? AuthError(from: response) {
                self.fail(with: error)
                return
            }
            
            let request = Request<OktaIdxAuth.Response>.SocialAuthenticateIOS13(options: options, completion: completion)
            request.send(to: self,
                         from: response)
        }
    }
    
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    @objc func socialAuth(completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        client.start { (context, response, error) in
            guard let response = response else {
                self.fail(with: AuthError.missingResponse)
                return
            }

            if let error = error ?? AuthError(from: response) {
                self.fail(with: error)
                return
            }
            
            let request = Request<OktaIdxAuth.Response>.SocialAuthenticate(completion: completion)
            request.send(to: self,
                         from: response)

        }
    }
    
    func changePassword(_ password: String,
                        completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        client.introspect { (response, error) in
            guard let response = response else {
                self.fail(with: AuthError.missingResponse)
                return
            }

            if let error = error ?? AuthError(from: response) {
                self.fail(with: error)
                return
            }
            
            let request = Request<OktaIdxAuth.Response>.ChangePassword(password: password,
                                                                       completion: completion)
            request.send(to: self,
                         from: response)
        }
    }
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
    }
    
    func verifyAuthenticator(code: String,
                             completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
    }
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        client.revoke(token: token, type: type.idxType) { (success, error) in
            guard let completion = completion else { return }
            if success {
                completion(.init(status: .tokenRevoked), nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
