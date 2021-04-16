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

import Foundation
import OktaIdx

protocol OktaIdxAuthImplementation {
    var delegate: OktaIdxAuthImplementationDelegate? { get set }
    
    func authenticate(username: String,
                      password: String?,
                      completion: OktaIdxAuth.ResponseResult?)
    
    func changePassword(_ password: String,
                        completion: OktaIdxAuth.ResponseResult?)
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult?)
    
    func verifyAuthenticator(code: String,
                             completion: OktaIdxAuth.ResponseResult?)
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult?)
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

        class Request {
            typealias Implementation = OktaIdxAuth.Implementation
            typealias Request = Implementation.Request
            typealias Response = OktaIdxAuth.Response
            typealias AuthError = OktaIdxAuth.Implementation.AuthError

            let completion: OktaIdxAuth.ResponseResult?
            
            init(completion:OktaIdxAuth.ResponseResult?) {
                self.completion = completion
            }
            
            func fatalError(_ error: Error) {
                completion?(nil, error)
            }
            
            func fatalError(_ error: AuthError) {
                completion?(nil, error)
            }
            
            func recoverableError(response: OktaIdxAuth.Response, error: AuthError) {
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
                guard let self = self as? Request & OktaIdxAuthRemediationRequest else {
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
                            
                            self.completion?(Response(status: .success,
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
            
            
            public class RecoverPassword: Request {
                public var username: String
                
                public init(implementation: Implementation,
                            with username: String,
                            completion: @escaping (OktaIdxAuth.Response?, Error?) -> Void) {
                    self.username = username
                    
                    super.init(completion: completion)
                }
            }
            
            
            public class VerifyAuthenticator: Request {
                public var code: String
                
                public init(implementation: Implementation,
                            with code: String,
                            completion: @escaping (OktaIdxAuth.Response?, Error?) -> Void) {
                    self.code = code
                    
                    super.init(completion: completion)
                }
            }
            
            public class RevokeToken: Request {
                public var type: TokenType
                
                public init(implementation: Implementation,
                            with type: TokenType,
                            completion: @escaping (OktaIdxAuth.Response?, Error?) -> Void) {
                    self.type = type
                    
                    super.init(completion: completion)
                }
            }
            
            public class Cancel: Request {
            }
            
            public class SelfServiceRegistration: Request {
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
                      completion: OktaIdxAuth.ResponseResult?)
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
            
            let request = Request.Authenticate(username: username,
                                               password: password,
                                               completion: completion)
            request.send(to: self,
                         from: response)
        }
    }
    
    func changePassword(_ password: String,
                        completion: OktaIdxAuth.ResponseResult?)
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
            
            let request = Request.ChangePassword(password: password,
                                                 completion: completion)
            request.send(to: self,
                         from: response)
        }
    }
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult?)
    {
    }
    
    func verifyAuthenticator(code: String,
                             completion: OktaIdxAuth.ResponseResult?)
    {
    }
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult?)
    {
    }
}
