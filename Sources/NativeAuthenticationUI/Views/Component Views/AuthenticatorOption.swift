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
extension AuthenticatorOption: ComponentView {
    @ViewBuilder
    public func body(in form: SignInForm, section: any SignInSection) -> some View {
        HStack(alignment: .firstTextBaseline) {
            switch name {
            case "email":
                Image(systemName: "envelope.circle")
                    .frame(width: 48, height: 48)
            case "phone":
                Image(systemName: "phone.circle")
                    .frame(width: 48, height: 48)
            case "password":
                Image(systemName: "lock.circle")
                    .frame(width: 48, height: 48)
            case "securityQuestion":
                Image(systemName: "questionmark.circle")
                    .frame(width: 48, height: 48)
            default:
                EmptyView()
                    .frame(width: 48, height: 48)
            }
            
            VStack(alignment: .leading) {
                if let label = label {
                    Text(label)
                        .font(.body)
                }
                
                if let profile = authenticator.profile {
                    Text(profile)
                        .font(.caption)
                }
            }
            
            if isCurrentOption {
                Image(systemName: "checkmark")
                    .frame(width: 48, height: 48)
            }
            
            if let action = action {
                Button("Select") {
                    action(self)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct AuthenticatorOption_Previews: PreviewProvider {
    static var previews: some View {
        let section = GenericSection {[]}
        let form = SignInForm(intent: .custom) {
            section
        }
        
        VStack(alignment: .leading, spacing: 20) {
            AuthenticatorOption(id: "email",
                                authenticator: EmailAuthenticator(id: "1", name: "email")
                .profile("j***@ex***ple.com"))
            .name("email")
            .label("Email")
            .isCurrentOption(false)
            .action({ _ in })
            .body(in: form, section: section)

            AuthenticatorOption(id: "email",
                                authenticator: EmailAuthenticator(id: "1", name: "email")
                .profile("+1 (555) ###-##78"))
            .name("phone")
            .label("Phone")
            .isCurrentOption(true)
            .action({ _ in })
            .body(in: form, section: section)

            AuthenticatorOption(id: "password",
                                authenticator: EmailAuthenticator(id: "1", name: "password"))
            .name("password")
            .label("Password")
            .action({ _ in })
            .body(in: form, section: section)

            AuthenticatorOption(id: "securityQuestion",
                                authenticator: EmailAuthenticator(id: "1", name: "securityQuestion")
                .profile("What's your favorite food?"))
            .name("securityQuestion")
            .label("Security Question")
            .action({ _ in })
            .body(in: form, section: section)
        }
        .padding(20)
    }
}
#endif
