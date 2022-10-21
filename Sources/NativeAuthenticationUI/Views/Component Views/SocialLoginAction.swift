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

import SwiftUI
import NativeAuthentication

#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SocialLoginAction: ComponentView {
    @ViewBuilder
    func body(in form: SignInForm, section: SignInSection) -> some View {
        switch provider {
        case .apple:
#if canImport(AuthenticationServices)
                if #available(iOS 14.0, *) {
                    SignInWithAppleButton { request in
                        // Do nothing
                    } onCompletion: { result in
                        // Do nothing
                    }.frame(maxHeight: 50)
                } else {
                    EmptyView()
                }
#else
                fallthrough
#endif
            
        default:
            if #available(iOS 15.0, *) {
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
            }
        }
    }
}
