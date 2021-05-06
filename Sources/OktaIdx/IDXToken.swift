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

extension IDXClient {
    /// Access tokens created as a result of exchanging a successful workflow response.
    @objc(IDXToken)
    public final class Token: NSObject, Codable {
        /// The access token to use.
        @objc public let accessToken: String
        
        /// The refresh token, if available.
        @objc public let refreshToken: String?
        
        /// The time interval after which this token will expire.
        @objc public let expiresIn: TimeInterval
        
        /// The ID token JWT string.
        @objc public let idToken: String?
        
        /// The access scopes for this token.
        @objc public let scope: String
        
        /// The type of this token.
        @objc public let tokenType: String

        /// The possible token types that can be revoked.
        @objc public enum RevokeType: Int {
            case refreshToken
            case accessAndRefreshToken
        }

        internal init(accessToken: String,
                      refreshToken: String?,
                      expiresIn: TimeInterval,
                      idToken: String?,
                      scope: String,
                      tokenType: String)
        {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiresIn = expiresIn
            self.idToken = idToken
            self.scope = scope
            self.tokenType = tokenType
            
            super.init()
        }
    }
}
