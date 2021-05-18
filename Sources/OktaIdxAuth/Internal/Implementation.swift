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
    var queue: DispatchQueue { get }
    var configuration: IDXClient.Configuration? { get }

    func client(reset: Bool, completion: @escaping (IDXClientAPI) -> Void)
    func succeeded(with response: IDXClient.Response, completion: @escaping(IDXClient.Token?, Error?) -> Void)
    func fail(with error: Error)

    func authenticate(username: String,
                      password: String?,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension 13.0, *)
    func socialAuth(with options: OktaIdxAuth.SocialOptions,
                    completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    func socialAuth(completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func changePassword(_ password: String,
                        from response: OktaIdxAuth.Response,
                        completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.Authenticator.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func select(authenticator: OktaIdxAuth.Authenticator.AuthenticatorType,
                from idxResponse: IDXClient.Response,
                completion: @escaping OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>)

    func verify(authenticator: OktaIdxAuth.Authenticator,
                with result: [String:String],
                completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func enroll(authenticator: OktaIdxAuth.Authenticator,
                with result: [String:String],
                completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)

    func register(firstName: String,
                  lastName: String,
                  email: String,
                  completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
}

protocol OktaIdxAuthImplementationDelegate: class {
    func didReceive(context: IDXClient.Context)
    func didSucceed(with token: IDXClient.Token)
    func didFail(with error: Error)
}

protocol OktaIdxAuthRemediationRequest {
    func send(to implementation: OktaIdxAuthImplementation,
              from response: IDXClient.Response?)
}

extension OktaIdxAuth {
    class Implementation {
        let configuration: IDXClient.Configuration?
        var context: IDXClient.Context?
        let queue: DispatchQueue
        
        private var storedClient: IDXClientAPI? {
            didSet {
                guard let context = storedClient?.context else { return }
                delegate?.didReceive(context: context)
            }
        }
        
        var delegate: OktaIdxAuthImplementationDelegate?
        
        init(with context: IDXClient.Context, queue: DispatchQueue) {
            self.context = context
            self.configuration = context.configuration
            self.queue = queue
        }

        init(with configuration: IDXClient.Configuration, queue: DispatchQueue) {
            self.configuration = configuration
            self.queue = queue
        }
        
        func client(reset: Bool = false, completion: @escaping (IDXClientAPI) -> Void) {
            if reset {
                storedClient = nil
                context = nil
            }
            
            if let client = storedClient {
                completion(client)
            }
            
            else if let configuration = configuration {
                IDXClient.start(with: configuration) { (client, error) in
                    guard let client = client else {
                        self.fail(with: error ?? AuthError.internalError(message: "Could not create an IDX client"))
                        return
                    }
                    self.storedClient = client
                    self.context = client.context
                    completion(client)
                }
            }
            
            else if let context = context {
                let client = IDXClient(context: context)
                self.storedClient = client
                completion(client)
            }
            
            else {
                self.fail(with: AuthError.internalError(message: "No client or configuration available"))
            }
        }

        func resume(reset: Bool = false, completion: @escaping (IDXClientAPI, IDXClient.Response) -> Void) {
            client(reset: reset) { (client) in
                client.resume { (response, error) in
                    guard let response = response else {
                        self.fail(with: error ?? AuthError.missingResponse)
                        return
                    }
                    
                    completion(client, response)
                }
            }
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
            
            func hasError(implementation: OktaIdxAuthImplementation,
                          in response: IDXClient.Response) -> Bool
            {
                guard !response.messages.isEmpty else { return false }

                completion?(T(with: implementation,
                              status: .unknown,
                              detailedResponse: response),
                            AuthError(from: response.messages.first))
                return true
            }
            
            func needsAdditionalRemediation(using response: IDXClient.Response?, from implementation: OktaIdxAuthImplementation) {
                guard let completion = completion else {
                    fatalError(.unexpectedTransitiveRequest)
                    return
                }

                if let response = response,
                   response.remediations[.selectAuthenticatorEnroll] != nil
                {
                    let response = T(with: implementation,
                                     status: .enrollAuthenticator,
                                     availableAuthenticators: response.availableAuthenticators,
                                     detailedResponse: response)
                    completion(response, nil)
                } else {
                    fatalError(.unexpectedTransitiveRequest)
                }
            }
            
            func proceed(to implementation: OktaIdxAuthImplementation, using option: IDXClient.Remediation) {
                guard let self = self as? Request<T> & OktaIdxAuthRemediationRequest else {
                    fatalError(.unexpectedTransitiveRequest)
                    return
                }

                option.proceed { (response, error) in
                    guard let response = response else {
                        self.fatalError(.missingRemediation)
                        return
                    }
                    
                    if let error = error ?? AuthError(from: response) {
                        self.fatalError(error)
                        return
                    }

                    guard !self.hasError(implementation: implementation, in: response) else { return }

                    if response.isLoginSuccessful {
                        implementation.succeeded(with: response) { (token, error) in
                            guard let token = token else {
                                let error = error ?? AuthError.failedToExchangeToken
                                self.fatalError(error)
                                return
                            }
                            
                            self.completion?(T(with: implementation,
                                               status: .success,
                                               detailedResponse: nil),
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
        case missingExpectedFormField
        case unsupportedAuthenticator
        case unexpectedTransitiveRequest
        case serverError(message: String)
        case failedToExchangeToken
        case internalError(message: String)

        init?(from response: IDXClient.Response) {
            guard let message = response.messages.first else {
                return nil
            }
            
            self.init(from: message)
        }
        
        init?(from message: IDXClient.Message?) {
            guard let message = message else { return nil }
            
            self = .serverError(message: message.message)
        }
        
        var errorDescription: String? {
            switch self {
            case .missingResponse:
                return "Missing a response"
            case .missingRemediation:
                return "Missing an expected remediation"
            case .missingExpectedFormField:
                return "Missing an expected form field"
            case .unsupportedAuthenticator:
                return "This authenticator is unsupported"
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
        resume(reset: true) { (client, response) in
            let request = Request<OktaIdxAuth.Response>.Authenticate(username: username,
                                                                     password: password,
                                                                     completion: completion)
            request.send(to: self, from: response)
        }
    }
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension 13.0, *)
    @objc func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        resume(reset: true) { (client, response) in
            let request = Request<OktaIdxAuth.Response>.SocialAuthenticateIOS13(options: options, completion: completion)
            request.send(to: self, from: response)
        }
    }
    
    @available(OSX 10.15, *)
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    @objc func socialAuth(completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?) {
        resume(reset: true) { (client, response) in
            let request = Request<OktaIdxAuth.Response>.SocialAuthenticate(completion: completion)
            request.send(to: self, from: response)
        }
    }
    
    func changePassword(_ password: String,
                        from response: OktaIdxAuth.Response,
                        completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        guard let idxResponse = response.detailedResponse else {
            completion?(nil, AuthError.missingResponse)
            return
        }
        
        let request = Request<OktaIdxAuth.Response>.ChangePassword(password: password,
                                                                   completion: completion)
        request.send(to: self, from: idxResponse)
    }
    
    func select(authenticator: OktaIdxAuth.Authenticator.AuthenticatorType,
                from idxResponse: IDXClient.Response,
                completion: @escaping OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>)
    {
        let request = Request<OktaIdxAuth.Response>.SelectAuthenticator(type: authenticator,
                                                                        response: idxResponse,
                                                                        completion: completion)
        request.send(to: self, from: idxResponse)
    }
    
    func enroll(authenticator: OktaIdxAuth.Authenticator,
                with result: [String : String],
                completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        let request = Request<OktaIdxAuth.Response>.EnrollAuthenticator(authenticator: authenticator,
                                                                        with: result,
                                                                        completion: completion)
        request.send(to: self)
    }
    
    func verify(authenticator: OktaIdxAuth.Authenticator,
                with result: [String : String],
                completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        let request = Request<OktaIdxAuth.Response>.VerifyAuthenticator(authenticator: authenticator,
                                                                        with: result,
                                                                        completion: completion)
        request.send(to: self)
    }
    
    func recoverPassword(username: String,
                         authenticator type: OktaIdxAuth.Authenticator.AuthenticatorType,
                         completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
    }
    
    func register(firstName: String,
                  lastName: String,
                  email: String,
                  completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        client(reset: true) { (client) in
            client.resume { (response, error) in
                guard let response = response else {
                    self.fail(with: AuthError.missingResponse)
                    return
                }
                
                if let error = error ?? AuthError(from: response) {
                    self.fail(with: error)
                    return
                }
                
                let request = Request<OktaIdxAuth.Response>.Register(firstName: firstName,
                                                                     lastName: lastName,
                                                                     email: email,
                                                                     completion: completion)
                request.send(to: self,
                             from: response)
            }
        }
    }
    
    func revokeTokens(token: String,
                      type: OktaIdxAuth.TokenType,
                      completion: OktaIdxAuth.ResponseResult<OktaIdxAuth.Response>?)
    {
        client { (client) in
            client.revoke(token: token, type: type.idxType) { (success, error) in
                guard let completion = completion else { return }
                if success {
                    completion(.init(with: self,
                                     status: .tokenRevoked,
                                     detailedResponse: nil),
                               nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
}
