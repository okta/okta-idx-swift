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
    @objc(IDXAuthenticatorCollection)
    public class AuthenticatorCollection: NSObject {
        @objc
        public var current: Authenticator? {
            allAuthenticators.values.first { $0.state == .authenticating || $0.state == .enrolling }
        }
        
        @objc
        public var enrolled: [Authenticator] {
            allAuthenticators.values.filter { $0.state == .enrolled }
        }
        
        @objc
        public subscript(type: Authenticator.Kind) -> Authenticator? {
            allAuthenticators[type]
        }
        
        public typealias DictionaryType = [IDXClient.Authenticator.Kind: IDXClient.Authenticator]
        
        var allAuthenticators: DictionaryType {
            authenticators
        }
        
        let authenticators: DictionaryType
        init(authenticators: DictionaryType?) {
            self.authenticators = authenticators ?? DictionaryType()

            super.init()
        }
    }
    
    class WeakAuthenticatorCollection: AuthenticatorCollection {
        typealias DictionaryType = [IDXClient.Authenticator.Kind: Weak<IDXClient.Authenticator>]

        override var allAuthenticators: AuthenticatorCollection.DictionaryType {
            weakAuthenticators.reduce(into: [IDXClient.Authenticator.Kind:IDXClient.Authenticator]()) { (result, item) in
                result[item.key] = item.value.object
            }
        }
        
        let weakAuthenticators: DictionaryType
        override init(authenticators: AuthenticatorCollection.DictionaryType?) {
            weakAuthenticators = authenticators?.reduce(into: DictionaryType(), { (result, item) in
                result[item.key] = Weak(object: item.value)
            }) ?? DictionaryType()

            super.init(authenticators: nil)
        }
    }
}
