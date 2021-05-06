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
    
    public typealias ResponseResult<T: Response> = (_ response: T?, _ error: Swift.Error?) -> Void
    
    @objc
    public convenience init(issuer: String,
                            clientId: String,
                            clientSecret: String?,
                            scopes: [String],
                            redirectUri: String,
                            completion: @escaping IDXClient.TokenResult)
    {
        let configuration = IDXClient.Configuration(issuer: issuer,
                                                    clientId: clientId,
                                                    clientSecret: clientSecret,
                                                    scopes: scopes,
                                                    redirectUri: redirectUri)
        self.init(with: OktaIdxAuth.Implementation(with: configuration),
                  completion: completion)
    }

    @objc
    public convenience init(with context: IDXClient.Context,
                            completion: @escaping IDXClient.TokenResult)
    {
        self.init(with: OktaIdxAuth.Implementation(with: context),
                  completion: completion)
    }
    
    @objc(OktaIdxAuthStatus)
    public enum Status: Int {
        case success
        case passwordInvalid
        case passwordExpired
        case tokenRevoked
        case unknown
    }

    @objc(OktaIdxAuthAuthenticatorType)
    public enum AuthenticatorType: Int {
        case email, sms
    }
   
    @objc(OktaIdxAuthTokenType)
    public enum TokenType: Int {
        case accessAndRefreshToken, refreshToken
    }

    @objc(OktaIdxAuthResponse)
    public class Response: NSObject {
        @objc
        public let status: Status
        
        @objc
        public let token: IDXClient.Token?
        
        @objc
        public let context: IDXClient.Context?
        
        @objc
        public let detailedResponse: IDXClient.Response?
        
        required init(status: Status,
                      token: IDXClient.Token? = nil,
                      context: IDXClient.Context? = nil,
                      detailedResponse: IDXClient.Response? = nil)
        {
            self.status = status
            self.token = token
            self.context = context
            self.detailedResponse = detailedResponse
            
            super.init()
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
    
    init(with implementation: OktaIdxAuthImplementation, completion: @escaping IDXClient.TokenResult) {
        self.implementation = implementation
        self.completion = completion
        
        super.init()
        
        self.implementation.delegate = self
    }
    
    @objc
    public func authenticate(username: String,
                             password: String?,
                             completion: ResponseResult<Response>? = nil)
    {
        implementation.authenticate(username: username, password: password, completion: completion)
    }
    
    @available(iOSApplicationExtension 13.0, *)
    @objc
    public func socialAuth(with options: OktaIdxAuth.SocialOptions, completion: ResponseResult<Response>? = nil)
    {
        implementation.socialAuth(with: options, completion: completion)
    }
    
    @available(iOSApplicationExtension, introduced: 12.0, deprecated: 13.0)
    @objc
    public func socialAuth(completion: ResponseResult<Response>? = nil)
    {
        implementation.socialAuth(completion: completion)
    }
    
    @objc
    public func changePassword(_ password: String,
                               completion: ResponseResult<Response>? = nil)
    {
        implementation.changePassword(password,
                                      completion: completion)
    }
    
    @objc
    public func recoverPassword(username: String,
                                authenticator type: AuthenticatorType,
                                completion: ResponseResult<Response>? = nil)
    {
        implementation.recoverPassword(username: username,
                                       authenticator: type,
                                       completion: completion)
    }
    
    @objc
    public func verifyAuthenticator(code: String,
                                    completion: ResponseResult<Response>? = nil)
    {
        implementation.verifyAuthenticator(code: code,
                                           completion: completion)
    }
    
    @objc
    public func revokeTokens(token: String,
                             type: TokenType,
                             completion: ResponseResult<Response>? = nil)
    {
        implementation.revokeTokens(token: token,
                                    type: type,
                                    completion: completion)
    }
}

extension OktaIdxAuth: OktaIdxAuthImplementationDelegate {
    func didSucceed(with token: IDXClient.Token) {
        completion(token, nil)
    }
    
    func didFail(with error: Error) {
        completion(nil, error)
    }
}
