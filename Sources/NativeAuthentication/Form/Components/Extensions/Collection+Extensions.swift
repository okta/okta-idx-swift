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

extension Collection where Element == any SignInComponent {
    public func with<T: SignInComponent>(type: T.Type) -> [T] {
        compactMap({ $0 as? T })
    }
    
    public func first<T: SignInComponent>(type: T.Type) -> T? {
        first(where: { $0 is T }) as? T
    }
    
    public func with<T: SignInComponent>(id: String) -> T? {
        with(type: T.self).first(where: { $0.id == id })
    }
}

extension Collection where Element == SignInSection {
    public func with(id: String) -> Element? {
        first(where: { $0.id == id })
    }
    
    public func containing(id: String) -> SignInSection? {
        first(where: { $0.components.contains { $0.id == id }})
    }
}

extension SignInSection {
    public func component<T: SignInComponent>(with id: String) -> T? {
        components.first { component in
            component is T && (component.id == self.id + "." + id ||
                               component.id == id)
        } as? T
    }
}
