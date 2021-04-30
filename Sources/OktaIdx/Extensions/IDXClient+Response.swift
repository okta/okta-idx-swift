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

public extension IDXClient {
        
//    /// Represents information describing the available authenticators and enrolled authenticators.
//    @objc(IDXAuthenticator)
//    class Authenticator: NSObject {
//        @objc(IDXAuthenticatorType)
//        public enum AuthenticatorType: Int {
//            case unknown
//            case app
//            case email
//            case phone
//            case password
//            case security_question
//            case device
//            case security_key
//            case federated
//        }
//
//        @objc(IDXAuthenticatorMethodType)
//        public enum AuthenticatorMethodType: Int {
//            case unknown
//            case sms
//            case voice
//            case email
//            case push
//            case crypto
//            case signedNonce
//            case totp
//            case password
//            case webauthn
//            case security_question
//        }
//        
//        /// Describes details about the current authenticator enrollment being verified, and any extra actions that may be taken.
//        @objc(IDXCurrentAuthenticatorEnrollment)
//        public final class CurrentEnrollment: Authenticator {
//            @objc public let send: Remediation.Option?
//            @objc public let resend: Remediation.Option?
//            @objc public let poll: Remediation.Option?
//            @objc public let recover: Remediation.Option?
//
//            internal init(id: String,
//                          displayName: String,
//                          type: String,
//                          key: String?,
//                          methods: [[String:String]]?,
//                          profile: [String:String]?,
//                          contextualData: [String:Any]?,
//                          send: Remediation.Option?,
//                          resend: Remediation.Option?,
//                          poll: Remediation.Option?,
//                          recover: Remediation.Option?)
//            {
//                self.send = send
//                self.resend = resend
//                self.poll = poll
//                self.recover = recover
//             
//                super.init(id: id, displayName: displayName, type: type, key: key, methods: methods, profile: profile, settings: nil, contextualData: contextualData)
//            }
//        }
//        
//        /// Unique identifier for this enrollment
//        @objc(identifier)
//        public let id: String
//
//        /// The user-visible name to use for this authenticator enrollment.
//        @objc public let displayName: String
//
//        /// The type of this authenticator, or `unknown` if the type isn't represented by this enumeration.
//        @objc public let type: AuthenticatorType
//        
//        /// The key name for the authenticator
//        @objc public let key: String?
//
//        /// The string representation of this type.
//        @objc public let typeName: String
//        @objc public let profile: [String:String]?
//        
//        /// Describes the various
//        @nonobjc public let methods: [AuthenticatorMethodType]?
//        @objc public let methodNames: [String]?
//        
//        /// Any settings relevant to this authenticator, if applicable.
//        @objc public let settings: Any?
//
//        /// Data that is relevant within the context of this authenticator, such as security questions or WebAuthN.
//        @objc public let contextualData: Any?
//
//        internal init(id: String,
//                      displayName: String,
//                      type: String,
//                      key: String?,
//                      methods: [[String:String]]?,
//                      profile: [String:String]?,
//                      settings: Any?,
//                      contextualData: Any?)
//        {
//            self.id = id
//            self.displayName = displayName
//            self.type = AuthenticatorType(string: type)
//            self.typeName = type
//            self.key = key
//            self.methods = methods?.compactMap {
//                guard let type = $0["type"] else { return nil }
//                return AuthenticatorMethodType(string: type)
//            }
//            self.methodNames = methods?.compactMap { $0["type"] }
//            self.profile = profile
//            self.settings = settings
//            self.contextualData = contextualData
//            
//            super.init()
//        }
//    }
}
