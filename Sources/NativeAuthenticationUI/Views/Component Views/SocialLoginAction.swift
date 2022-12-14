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

struct SocialIDPLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            configuration.icon
            configuration.title
        }.frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
extension SocialLoginAction: ComponentView {
    @ViewBuilder
    func body(in form: SignInForm, section: any SignInSection) -> some View {
        switch provider {
        case .okta:
            if #available(iOS 15.0, macOS 12.0, *) {
                Button {
                    self.action()
                } label: {
                    Label {
                        Text(label)
                            .padding(.vertical, 3.0)
                            .foregroundColor(Color.primary)
                    } icon: {
                        Image(decorative: "okta_verify", bundle: .module)
                            .aspectRatio(1.0, contentMode: .fit)
                    }
                }
                .labelStyle(SocialIDPLabelStyle())
                .buttonStyle(.bordered)
            } else {
                Button {
                    self.action()
                } label: {
                    HStack {
                        Image(decorative: "okta_verify")
                        Text(label)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 3.0)
                            .foregroundColor(Color.primary)
                    }
                }
                .padding(.top)
            }

        case .apple:
#if canImport(AuthenticationServices) && os(iOS)
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
                EmptyView()
#endif
            
        default:
            if #available(iOS 15.0, macOS 12.0, *) {
                Button {
                    self.action()
                } label: {
                    Text(label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3.0)
                }
                .padding(.top)
                .labelStyle(SocialIDPLabelStyle())
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

#if DEBUG
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct SocialLoginAction_Previews: PreviewProvider {
    static var previews: some View {
        let section = GenericSection {[]}
        let form = SignInForm(intent: .custom) {
            section
        }
        
        VStack(spacing: 20) {
            SocialLoginAction(id: "okta", provider: .okta, label: "Sign in with Okta FastPass") {}
                .body(in: form, section: section)
            SocialLoginAction(id: "apple", provider: .apple, label: "Sign in with Apple") {}
                .body(in: form, section: section)
            SocialLoginAction(id: "facebook", provider: .facebook, label: "Sign in with Facebook") {}
                .body(in: form, section: section)
            SocialLoginAction(id: "google", provider: .google, label: "Sign in with Google") {}
                .body(in: form, section: section)
        }
        .padding(20)
    }
}
#endif
