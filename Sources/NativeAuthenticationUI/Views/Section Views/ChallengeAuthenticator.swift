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

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
extension ChallengeAuthenticator: SectionView {
    @ViewBuilder
    func body(in form: SignInForm, @ViewBuilder renderer: ([any SignInComponent]) -> some View) -> any View {
        VStack(spacing: 12.0) {
            Text("Verify with your \(authenticator.name.lowercased())")
                .font(.headline)
                .fontWeight(.bold)
            
            if let profile = authenticator.profile {
                HStack {
                    Image(systemName: "person.circle")
                    Text(profile)
                        .font(.subheadline)
                }

                Text("We sent a verification code to \(profile). Click the verification link in your email to continue or enter the code below.")
            }
            
            renderer(components)
        }.padding(.bottom, 12.0)
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct ChallengeAuthenticatorView<Content: View>: View {
    let authenticator: any Authenticator
    let content: () -> Content
    
    init(authenticator: any Authenticator, @ViewBuilder content: @escaping () -> Content) {
        self.authenticator = authenticator
        self.content = content
    }

    var body: some View {
        VStack(spacing: 12.0) {
            Text("Verify with your \(authenticator.name.lowercased())")
                .font(.headline)
                .fontWeight(.bold)
            
            if let profile = authenticator.profile {
                HStack {
                    Image(systemName: "person.circle")
                    Text(profile)
                        .font(.subheadline)
                }

                Text("We sent a verification code to \(profile). Click the verification link in your email to continue or enter the code below.")
            } else {
                Text("We sent you a verification code. Please check your \(authenticator.name.lowercased()) and the code below.")
            }
            
            content()
        }.padding(.bottom, 12.0)
    }
}

#if DEBUG
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct ChallengeAuthenticatorView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeAuthenticatorView(authenticator: EmailAuthenticator(id: "email", name: "Email")
            .profile("mike@*****ur.com")
            .displayName("Email")) {
            }
    }
}
#endif
