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
    /// Remediation subclass used to represent passcode challenge remediations (e.g. password, verification code, etc).
    @objc(IDXChallengeRemediation)
    public class Challenge: IDXClient.Remediation {
        /// The field representing the user's passcode.
        @objc public var passcodeField: Form.Field

        internal required init?(client: IDXClientAPI,
                                name: String,
                                method: String,
                                href: URL,
                                accepts: String?,
                                form: Form,
                                refresh: TimeInterval? = nil,
                                relatesTo: [String]? = nil)
        {
            guard let passcodeField = form["credentials.passcode"] else { return nil }
            
            self.passcodeField = passcodeField
            
            super.init(client: client,
                       name: name,
                       method: method,
                       href: href,
                       accepts: accepts,
                       form: form,
                       refresh: refresh,
                       relatesTo: relatesTo)
        }
        
        /// Verify the challenge with the given passcode.
        /// - Parameters:
        ///   - passcode: Passcode to supply to the challenge remediation.
        ///   - completion: Completion handler invoked when a result is received.
        public func verify(passcode: String, completion: IDXClient.ResponseResult? = nil) {
            passcodeField.value = passcode
            proceed(completion: completion)
        }
        
        /// Verify the challenge with the given passcode.
        /// - Parameters:
        ///   - passcode: Passcode to supply to the challenge remediation.
        ///   - completion: Completion handler invoked when a result is received.
        @objc public func verify(passcode: String, completion: IDXClient.ResponseResultCallback?) {
            verify(passcode: passcode) { result in
                switch result {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
}
