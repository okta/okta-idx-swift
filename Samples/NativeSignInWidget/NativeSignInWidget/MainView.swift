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
import AuthenticationServices
import NativeAuthenticationUI
import DynamicAuthentication

struct MainView: View {
    let credential: Credential
    
    var body: some View {
        Form(content: {
            Section(header: Text("Profile")) {
                HStack {
                    Text("Given name")
                    Spacer()
                    Text(credential.token.idToken?.givenName ?? "N/A")
                }
                HStack {
                    Text("Family name")
                    Spacer()
                    Text(credential.token.idToken?.familyName ?? "N/A")
                }
                HStack {
                    Text("Locale")
                    Spacer()
                    Text(credential.token.idToken?.userLocale?.identifier ?? "N/A")
                }
                HStack {
                    Text("Timezone")
                    Spacer()
                    Text(credential.token.idToken?.timeZone?.identifier ?? "N/A")
                }
            }
            Section(header: Text("Details")) {
                HStack {
                    Text("Username")
                    Spacer()
                    Text(credential.token.idToken?.preferredUsername ?? "N/A")
                }
                HStack {
                    Text("User ID")
                    Spacer()
                    Text(credential.token.idToken?.subject ?? "N/A")
                }
                HStack {
                    Text("Created at")
                    Spacer()
                    Text(credential.token.idToken?.issuedAt?.coordinated ?? Date(), style: .relative)
                }
                HStack {
                    Text("Expires in")
                    Spacer()
                    Text(credential.token.idToken?.expirationTime?.coordinated ?? Date(), style: .relative)
                }
                Button(action: {
                    Task {
                        try? await credential.refreshIfNeeded()
                    }
                }) {
                    Text("Refresh")
                }
            }
            Section {
                Button(role: .destructive, action: {
                    Task {
                        try? await credential.revoke()
                    }
                }) {
                    Text("Sign Out")
                }
            }
        })
    }
}
