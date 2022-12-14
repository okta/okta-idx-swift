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

public protocol SignInSection: Identifiable {
    var id: String? { get set }
    var components: [any SignInComponent] { get set }
}

public protocol Actionable {
    var action: ((_ component: any SignInComponent) -> Void)? { get set }
}

public protocol HasAuthenticator {
    var authenticator: any Authenticator { get set }
}
