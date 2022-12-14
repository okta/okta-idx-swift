//
// Copyright (c) 2022-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

extension Authenticator {
    /// Container that represents a collection of authenticators, providing conveniences for quickly accessing relevant objects.
    public class Challenge {
        public enum Method: String {
            case universalLink = "UNIVERSAL_LINK"
        }
        
        /// The current authenticator, if one is actively being enrolled or authenticated.
        public let href: URL
        
        init?(href: URL?) {
            guard let href = href else { return nil }
            self.href = href
        }
    }
}
