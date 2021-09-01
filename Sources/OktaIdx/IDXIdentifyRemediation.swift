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

extension IDXClient.Remediation {
    /// Remediation subclass that defines conveniences to simplify interactions with Identify remediation options.
    @objc(IDXIdentifyRemediation)
    public class Identify: IDXClient.Remediation {
        /// The field used to supply the username (aka "identifier") to the remediation.
        @objc public var identifierField: Form.Field
        
        /// The field representing the "Remember Me" option.
        @objc public var rememberMeField: Form.Field
        
        /// The field representing the user's password. This value may be nil when an identify-first policy is defined.
        @objc public var passwordField: Form.Field?
        
        internal required init?(client: IDXClientAPI,
                                name: String,
                                method: String,
                                href: URL,
                                accepts: String?,
                                form: Form,
                                refresh: TimeInterval? = nil,
                                relatesTo: [String]? = nil)
        {
            guard let identifierField = form["identifier"],
                  let rememberMeField = form["rememberMe"]
            else { return nil }
            
            self.identifierField = identifierField
            self.rememberMeField = rememberMeField
            self.passwordField = form["credentials.passcode"]
            
            super.init(client: client,
                       name: name,
                       method: method,
                       href: href,
                       accepts: accepts,
                       form: form,
                       refresh: refresh,
                       relatesTo: relatesTo)
        }
        
        /// Authenticate the user with the given username identifier, and optional password.
        /// - Parameters:
        ///   - identifier: Identifier (aka "username") to use.
        ///   - password: Optional password to supply.
        ///   - completion: Completion handler invoked when a response is received.
        public func authenticate(identifier: String, password: String? = nil, completion: IDXClient.ResponseResult? = nil) {
            identifierField.value = identifier
            passwordField?.value = password
            proceed(completion: completion)
        }

        /// Authenticate the user with the given username identifier, and optional password.
        /// - Parameters:
        ///   - identifier: Identifier (aka "username") to use.
        ///   - password: Optional password to supply.
        ///   - completion: Completion handler invoked when a response is received.
        @objc public func authenticate(identifier: String, password: String?, completion: IDXClient.ResponseResultCallback?) {
            authenticate(identifier: identifier, password: password) { result in
                switch result {
                case .success(let response):
                    completion?(response, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
}
