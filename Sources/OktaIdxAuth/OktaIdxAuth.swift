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
                            context: IDXClient.Context? = nil,
                            completion: @escaping IDXClient.TokenResult)
    {
        self.init(with: IDXClient(configuration: .init(issuer: issuer,
                                                       clientId: clientId,
                                                       clientSecret: clientSecret,
                                                       scopes: scopes,
                                                       redirectUri: redirectUri),
                                  context: context),
                  completion: completion)
    }

    @objc
    public convenience init(with client: IDXClient,
                            completion: @escaping IDXClient.TokenResult)
    {
        self.init(with: OktaIdxAuth.Implementation(with: client),
                  completion: completion)
    }
    
    @objc(OktaIdxAuthStatus)
    public enum Status: Int {
        case success
        case passwordInvalid
        case passwordExpired
        case tokenRevoked
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
        public let additionalInfo: [String: Any]?
        
        required init(status: Status,
                      token: IDXClient.Token? = nil,
                      context: IDXClient.Context? = nil,
                      additionalInfo: [String: Any]? = nil)
        {
            self.status = status
            self.token = token
            self.context = context
            self.additionalInfo = additionalInfo
            
            super.init()
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
