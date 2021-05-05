//
// Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
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

@objc(IDXAuthenticatorIsSendable)
public protocol Sendable {
    @objc func send(completion: IDXClient.ResponseResult?)
}

@objc(IDXAuthenticatorIsResendable)
public protocol Resendable {
    @objc func resend(completion: IDXClient.ResponseResult?)
}

@objc(IDXAuthenticatorIsRecoverable)
public protocol Recoverable {
    @objc func recover(completion: IDXClient.ResponseResult?)
}

@objc(IDXAuthenticatorIsCancellable)
public protocol Cancellable {
    @objc func cancel(completion: IDXClient.ResponseResult?)
}

@objc(IDXAuthenticatorIsPollable)
public protocol Pollable {
    @objc func startPolling(completion: IDXClient.ResponseResult?)
    @objc func stopPolling()
}

@objc(IDXAuthenticatorHasProfile)
public protocol HasProfile {
    @objc var profile: [String:String]? { get }
}

extension IDXClient {
    /// Represents information describing the available authenticators and enrolled authenticators.
    @objc(IDXAuthenticator)
    public class Authenticator: NSObject {
        /// Unique identifier for this enrollment
        @objc(identifier)
        public let id: String

        /// The user-visible name to use for this authenticator enrollment.
        @objc public let displayName: String

        /// The type of this authenticator, or `unknown` if the type isn't represented by this enumeration.
        @objc public let type: Kind
        
        /// The key name for the authenticator
        @objc public let key: String?
        
        /// Indicates the state of this authenticator, either being an available authenticator, an enrolled authenticator, authenticating, or enrolling.
        @objc public let state: State

        /// Describes the various
        @nonobjc public let methods: [Method]?
        @objc public let methodNames: [String]?
        
        // TODO: deviceKnown?
        // TODO: credentialId?
        
//        /// Data that is relevant within the context of this authenticator, such as security questions or WebAuthN.
//        @objc public let contextualData: Any?

        private weak var client: IDXClientAPI?
        let jsonPaths: [String]
        init(client: IDXClientAPI,
             v1JsonPaths: [String],
             state: State,
             id: String,
             displayName: String,
             type: String,
             key: String?,
             methods: [[String:String]]?)
        {
            self.client = client
            self.jsonPaths = v1JsonPaths
            self.state = state
            self.id = id
            self.displayName = displayName
            self.type = Kind(string: type)
            self.key = key
            self.methods = methods?.compactMap {
                guard let type = $0["type"] else { return nil }
                return Method(string: type)
            }
            self.methodNames = methods?.compactMap { $0["type"] }

            super.init()
        }
        
        @objc(IDXPasswordAuthenticator)
        public class Password: Authenticator {
            @objc public let settings: Settings?
            
            @objc(IDXPasswordSettings)
            public class Settings: NSObject {
                @objc public let daysToExpiry: Int
                @objc public let minLength: Int
                @objc public let minLowerCase: Int
                @objc public let minUpperCase: Int
                @objc public let minNumber: Int
                @objc public let minSymbol: Int
                @objc public let excludeUsername: Bool
                @objc public let excludeAttributes: [String]
                
                init(daysToExpiry: Int,
                     minLength: Int,
                     minLowerCase: Int,
                     minUpperCase: Int,
                     minNumber: Int,
                     minSymbol: Int,
                     excludeUsername: Bool,
                     excludeAttributes: [String])
                {
                    self.daysToExpiry = daysToExpiry
                    self.minLength = minLength
                    self.minLowerCase = minLowerCase
                    self.minUpperCase = minUpperCase
                    self.minNumber = minNumber
                    self.minSymbol = minSymbol
                    self.excludeUsername = excludeUsername
                    self.excludeAttributes = excludeAttributes

                    super.init()
                }
            }
            
            internal init(client: IDXClientAPI,
                          v1JsonPaths: [String],
                          state: State,
                          id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          settings: Settings?)
            {
                self.settings = settings

                super.init(client: client,
                           v1JsonPaths: v1JsonPaths,
                           state: state,
                           id: id,
                           displayName: displayName,
                           type: type,
                           key: key,
                           methods: methods)
            }
        }

        @objc(IDXProfileBaseAuthenticator)
        public class ProfileAuthenticator: Authenticator, HasProfile {
            @objc public let profile: [String:String]?
            
            internal init(client: IDXClientAPI,
                          v1JsonPaths: [String],
                          state: State,
                          id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          profile: [String:String]?)
            {
                self.profile = profile

                super.init(client: client,
                           v1JsonPaths: v1JsonPaths,
                           state: state,
                           id: id,
                           displayName: displayName,
                           type: type,
                           key: key,
                           methods: methods)
            }
        }
        
        @objc(IDXEmailAuthenticator)
        public class Email: ProfileAuthenticator, Resendable, Pollable {
            @objc public var emailAddress: String? { profile?["email"] }
            @objc public private(set) var isPolling: Bool = false
            
            public func resend(completion: IDXClient.ResponseResult?) {
                guard let client = client else {
                    completion?(nil, IDXClientError.invalidClient)
                    return
                }
                
                guard let resendOption = resendOption else {
                    completion?(nil, nil) // TODO: Send error
                    return
                }
                
                client.proceed(remediation: resendOption, completion: completion)
            }
            
            public func startPolling(completion: IDXClient.ResponseResult?) {
                isPolling = true
                // TODO: Add polling handler
            }
            
            public func stopPolling() {
                isPolling = false
            }
            
            internal let resendOption: IDXClient.Remediation?
            internal let pollOption: IDXClient.Remediation?
            
            internal init(client: IDXClientAPI,
                          v1JsonPaths: [String],
                          state: State,
                          id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          profile: [String:String]?,
                          resendOption: IDXClient.Remediation?,
                          pollOption: IDXClient.Remediation?)
            {
                self.resendOption = resendOption
                self.pollOption = pollOption

                super.init(client: client,
                           v1JsonPaths: v1JsonPaths,
                           state: state,
                           id: id,
                           displayName: displayName,
                           type: type,
                           key: key,
                           methods: methods,
                           profile: profile)
            }
        }

        @objc(IDXPhoneAuthenticator)
        public class Phone: ProfileAuthenticator, Sendable, Resendable {
            @objc public var phoneNumber: String? { profile?["phoneNumber"] }
            
            public func send(completion: IDXClient.ResponseResult?) {
                guard let client = client else {
                    completion?(nil, IDXClientError.invalidClient)
                    return
                }
                
                guard let sendOption = sendOption else {
                    completion?(nil, nil) // TODO: Send error
                    return
                }
                
                client.proceed(remediation: sendOption, completion: completion)
            }
            
            public func resend(completion: IDXClient.ResponseResult?) {
                guard let client = client else {
                    completion?(nil, IDXClientError.invalidClient)
                    return
                }
                
                guard let resendOption = resendOption else {
                    completion?(nil, nil) // TODO: Send error
                    return
                }
                
                client.proceed(remediation: resendOption, completion: completion)
            }
            
            internal let sendOption: IDXClient.Remediation?
            internal let resendOption: IDXClient.Remediation?
            internal init(client: IDXClientAPI,
                          v1JsonPaths: [String],
                          state: State,
                          id: String,
                          displayName: String,
                          type: String,
                          key: String?,
                          methods: [[String:String]]?,
                          profile: [String:String]?,
                          sendOption: IDXClient.Remediation?,
                          resendOption: IDXClient.Remediation?)
            {
                self.sendOption = sendOption
                self.resendOption = resendOption

                super.init(client: client,
                           v1JsonPaths: v1JsonPaths,
                           state: state,
                           id: id,
                           displayName: displayName,
                           type: type,
                           key: key,
                           methods: methods,
                           profile: profile)
            }
        }

        @objc(IDXSecurityQuestionAuthenticator)
        public class SecurityQuestion: ProfileAuthenticator {
            @objc public var question: String? { profile?["question"] }
            @objc public var questionKey: String? { profile?["question_key"] }
        }
    }
}
