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
import AuthenticationServices

@objc public class OktaIdxAuth: NSObject {
    var implementation: OktaIdxAuthImplementation
    let completion: IDXClient.TokenResult
    let queue: DispatchQueue
    
    public typealias ResponseResult<T: Response> = (_ response: T?, _ error: Swift.Error?) -> Void
    
    /// Initiates a new authentication workflow.
    /// - Parameters:
    ///   - issuer: Issuer URL
    ///   - clientId: Application's Client ID
    ///   - clientSecret: Application's Client Secret, or `nil` if unneeded
    ///   - scopes: Application's scopes
    ///   - redirectUri: Application's redirect URI
    ///   - queue: Dispatch queue used when invoking completion blocks. Default: `.main`
    ///   - completion: invoked either when a token is successfully exchanged, or when a fatal error occurs
    @objc public convenience init(issuer: String,
                                  clientId: String,
                                  clientSecret: String?,
                                  scopes: [String],
                                  redirectUri: String,
                                  queue: DispatchQueue = .main,
                                  completion: @escaping IDXClient.TokenResult)
    {
        let configuration = IDXClient.Configuration(issuer: issuer,
                                                    clientId: clientId,
                                                    clientSecret: clientSecret,
                                                    scopes: scopes,
                                                    redirectUri: redirectUri)
        self.init(with: OktaIdxAuth.Implementation(with: configuration, queue: queue),
                  queue: queue,
                  completion: completion)
    }
    
    /// Resumes an authentication workflow using the supplied context.
    /// - Parameters:
    ///   - context: Context to reinitialize the workflow with.
    ///   - queue: Dispatch queue used when invoking completion blocks. Default: `.main`
    ///   - completion: invoked either when a token is successfully exchanged, or when a fatal error occurs
    @objc public convenience init(with context: IDXClient.Context,
                                  queue: DispatchQueue = .main,
                                  completion: @escaping IDXClient.TokenResult)
    {
        self.init(with: OktaIdxAuth.Implementation(with: context, queue: queue),
                  queue: queue,
                  completion: completion)
    }
    
    /// The context object created as a part of the authentication process; can be serialized for later use.
    @objc private(set) public var context: IDXClient.Context?

    /// Enum of the possible statuses a response may return.
    @objc(OktaIdxAuthStatus)
    public enum Status: Int {
        case success
        case passwordInvalid
        case passwordExpired
        case tokenRevoked
        case enrollAuthenticator
        case verifyAuthenticator
        case unknown
        
        /// Returned when the given operation is unavailable at this point
        /// (e.g. calling changePassword when it's not a possible outcome of a given status, e.g. selectAuthenticatorAuthenticate)
        case operationUnavailable
    }
   
    /// The possible token types that can be revoked.
    @objc(OktaIdxAuthTokenType)
    public enum TokenType: Int {
        case accessAndRefreshToken, refreshToken
    }

    /// Object that describes the response from a call, and the possible next steps that can be taken.
    @objc(OktaIdxAuthResponse)
    public class Response: NSObject {
        /// The status of the response
        @objc public let status: Status
        
        @objc public let detailedResponse: IDXClient.Response?
        
        /// The list of possible authenticators, if any, that may be verified or enrolled.
        @nonobjc public let availableAuthenticators: [OktaIdxAuth.Authenticator.AuthenticatorType]
        
        /// The list of possible authenticators, if any, that may be verified or enrolled. (Objective-C compatability)
        @objc public var availableAuthenticatorNames: [String] {
            availableAuthenticators.map { $0.stringValue() }
        }

        /// An Authenticator object that describes the authenticator chosen, where verify or enrolment operations may be performed.
        ///
        /// If an error occurred while selecting the authenticator in a previous call, this value will be null, and the appropriate
        /// error status will be reported in `status`.
        @objc public let authenticator: OktaIdxAuth.Authenticator?

        /// Initiates a change password request, if available.
        @objc public func change(password: String,
                                 completion: @escaping ResponseResult<Response>)
        {
            let queue = implementation.queue
            implementation.changePassword(password, from: self) { (response, error) in
                queue.async {
                    completion(response, error)
                }
            }
        }
        
        /// Selects the given authenticator, either to verify or enroll
        @objc public func select(authenticator: OktaIdxAuth.Authenticator.AuthenticatorType,
                                 completion: @escaping ResponseResult<Response>)
        {
            let queue = implementation.queue
            guard let response = detailedResponse else {
                queue.async {
                    completion(nil, OktaIdxAuth.Implementation.AuthError.missingResponse)
                }
                return
            }
            
            implementation.select(authenticator: authenticator, from: response) { (response, error) in
                queue.async {
                    completion(response, error)
                }
            }
        }

        let implementation: OktaIdxAuthImplementation
        required init(with implementation: OktaIdxAuthImplementation,
                      status: Status,
                      availableAuthenticators: [Authenticator.AuthenticatorType] = [],
                      detailedResponse: IDXClient.Response?,
                      authenticator: OktaIdxAuth.Authenticator? = nil)
        {
            self.implementation = implementation
            self.status = status
            self.detailedResponse = detailedResponse
            self.availableAuthenticators = availableAuthenticators
            self.authenticator = authenticator
            
            super.init()
        }
    }
    
    /// Describes an authenticator, and any associated information that may be relevant.
    @objc(OktaIdxAuthAuthenticator)
    public class Authenticator: NSObject {
        /// Enum value describing the authenticator; can be used to determine what class to cast this object to.
        @objc public let type: AuthenticatorType
        
        /// Verify the authenticator with the given value
        @objc public func verify(with result: String,
                                 completion: @escaping ResponseResult<Response>)
        {
            let queue = implementation.queue
            implementation.verify(authenticator: self,
                                  with: ["credentials.passcode": result])
            { (response, error) in
                queue.async {
                    completion(response, error)
                }
            }
        }
        
        func enroll(using result: [String:String], completion: @escaping ResponseResult<Response>) {
            let queue = implementation.queue
            implementation.enroll(authenticator: self,
                                  with: result)
            { (response, error) in
                queue.async {
                    completion(response, error)
                }
            }
        }

        let implementation: OktaIdxAuthImplementation
        let remediation: IDXClient.Remediation
        required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation, type: AuthenticatorType) {
            self.implementation = implementation
            self.remediation = remediation
            self.type = type
            
            super.init()
        }
        
        @objc(OktaIdxAuthAuthenticatorType)
        public enum AuthenticatorType: Int {
            case phone, email, password, skip
        }
        
        @objc(OktaIdxAuthPasswordAuthenticator)
        public class Password: Authenticator {
            @objc public func enroll(password: String, completion: @escaping ResponseResult<Response>) {
                enroll(using: ["credentials.passcode": password], completion: completion)
            }
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation, type: AuthenticatorType) {
                fatalError("init(implementation:type:) has not been implemented")
            }
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation) {
                super.init(implementation: implementation, remediation: remediation, type: .password)
            }
        }

        @objc(OktaIdxAuthPhoneAuthenticator)
        public class Phone: Authenticator {
            @objc public func enroll(phoneNumber: String,
                                     method: Method,
                                     completion: @escaping ResponseResult<Response>)
            {}
            
            /// Select the phone authenticator method
            @objc public func select(method: Method,
                                     completion: @escaping ResponseResult<Response>)
            {
            }
            
            @objc(OktaIdxAuthPhoneAuthenticatorMethod)
            public enum Method: Int {
                case sms, voice
            }
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation, type: AuthenticatorType) {
                fatalError("init(implementation:type:) has not been implemented")
            }
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation) {
                super.init(implementation: implementation, remediation: remediation, type: .phone)
            }
        }

        @objc(OktaIdxAuthPhoneAuthenticator)
        public class Email: Authenticator {
            @objc public func enroll(email: String,
                                     completion: @escaping ResponseResult<Response>)
            {}
            
            /// Initiates a polling operation out-of-band, and returns the result if the user clicks the magic link.
            /// Otherwise, the `enroll(email:completion:)` method may be used concurrently.
            @objc public func poll(completion: @escaping ResponseResult<Response>) {}
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation, type: AuthenticatorType) {
                fatalError("init(implementation:type:) has not been implemented")
            }
            
            required init(implementation: OktaIdxAuthImplementation, remediation: IDXClient.Remediation) {
                super.init(implementation: implementation, remediation: remediation, type: .email)
            }
        }
    }


    @objc(OktaIdxAuthSocialOptions)
    @available(iOSApplicationExtension 13.0, *)
    public class SocialOptions: NSObject {
        @objc
        public let presentationContext: ASWebAuthenticationPresentationContextProviding
        
        @objc
        public let prefersEphemeralSession: Bool
        
        public init(presentationContext: ASWebAuthenticationPresentationContextProviding, prefersEphemeralSession: Bool) {
            self.presentationContext = presentationContext
            self.prefersEphemeralSession = prefersEphemeralSession
        }
    }
    
    init(with implementation: OktaIdxAuthImplementation, queue: DispatchQueue, completion: @escaping IDXClient.TokenResult) {
        self.implementation = implementation
        self.queue = queue
        self.completion = completion
        
        super.init()
        
        self.implementation.delegate = self
    }
    
    /// Authenticates using username/password
    @objc public func authenticate(username: String,
                                   password: String?,
                                   completion: @escaping ResponseResult<Response>)
    {
        implementation.authenticate(username: username, password: password) { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
    
    /// Authenticates using IDP
    @available(iOSApplicationExtension 13.0, *)
    @objc public func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: @escaping ResponseResult<Response>)
    {
        implementation.socialAuth(with: options) { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
    
    /// Authenticates using IDP (on older iOS versions)
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    @objc public func socialAuth(completion: @escaping ResponseResult<Response>)
    {
        implementation.socialAuth { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
    
    @objc public func recoverPassword(username: String,
                                      authenticator type: Authenticator.AuthenticatorType,
                                      completion: @escaping ResponseResult<Response>)
    {
        implementation.recoverPassword(username: username,
                                       authenticator: type) { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
    
    @objc public func register(firstName: String,
                               lastName: String,
                               email: String,
                               completion: @escaping ResponseResult<Response>)
    {
        implementation.register(firstName: firstName,
                                lastName: lastName,
                                email: email) { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
    
    @objc public func revokeTokens(token: String,
                                   type: TokenType,
                                   completion: @escaping ResponseResult<Response>)
    {
        implementation.revokeTokens(token: token,
                                    type: type) { (response, error) in
            self.queue.async {
                completion(response, error)
            }
        }
    }
}

extension OktaIdxAuth: OktaIdxAuthImplementationDelegate {
    func didReceive(context: IDXClient.Context) {
        self.context = context
    }
    
    func didSucceed(with token: IDXClient.Token) {
        queue.async {
            self.completion(token, nil)
        }
    }
    
    func didFail(with error: Error) {
        queue.async {
            self.completion(nil, error)
        }
    }
}
