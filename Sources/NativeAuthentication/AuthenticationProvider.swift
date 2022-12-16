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
@_exported import AuthFoundation

public protocol AuthenticationProviderDelegate {
    func authentication(provider: any AuthenticationProvider, updated form: SignInForm)
    func authentication(provider: any AuthenticationProvider, finished token: Token)
    func authentication(provider: any AuthenticationProvider, idp: RedirectIDP.Provider, redirectTo url: URL, callback scheme: String)
}

public protocol AuthenticationProvider: UsesDelegateCollection where Delegate == AuthenticationProviderDelegate {
    func signIn() async
    func transitioned(to state: AuthenticationClient.UIState)
    func idp(_ idp: RedirectIDP.Provider, finished callbackURL: URL)
    func idp(_ idp: RedirectIDP.Provider, error: Error)
}
