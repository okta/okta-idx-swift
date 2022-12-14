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

public struct ChangePassword: SignInSection, Actionable, HasAuthenticator, Identifiable {
    public var id: String?
    public var authenticator: any Authenticator
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, authenticator: any Authenticator, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.authenticator = authenticator
        self.components = components()
    }
}
