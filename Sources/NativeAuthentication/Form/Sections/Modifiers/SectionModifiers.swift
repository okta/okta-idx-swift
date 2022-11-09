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

extension SignInSection {
    public func id(_ id: String) -> Self {
        var result = self
        result.id = id
        return result
    }
    
    public func components(@ArrayBuilder<any SignInComponent> _ components: () -> [any SignInComponent]) -> Self {
        var result = self
        result.components = components()
        return result
    }
}

extension Actionable {
    public func action(_ action: @escaping (_ component: any SignInComponent) -> Void) -> Self {
        var result = self
        result.action = action
        return result
    }
}
