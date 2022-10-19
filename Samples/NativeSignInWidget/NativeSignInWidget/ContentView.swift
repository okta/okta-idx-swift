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

struct ContentView: View {
    let auth: NativeAuthentication
    
    var body: some View {
        if let credential = Credential.default,
           let token = credential.token.idToken
        {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Given name")
                        Spacer()
                        Text(token.givenName ?? "N/A")
                    }
                    HStack {
                        Text("Family name")
                        Spacer()
                        Text(token.familyName ?? "N/A")
                    }
                    HStack {
                        Text("Locale")
                        Spacer()
                        Text(token.userLocale?.identifier ?? "N/A")
                    }
                    HStack {
                        Text("Timezone")
                        Spacer()
                        Text(token.timeZone?.identifier ?? "N/A")
                    }
                }
                Section(header: Text("Details")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(token.preferredUsername ?? "N/A")
                    }
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(token.subject ?? "N/A")
                    }
                    HStack {
                        Text("Created at")
                        Spacer()
                        Text(token.issuedAt?.coordinated ?? Date(), style: .relative)
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
            }
        } else {
            auth.rendererView() { token in
                try? Credential.store(token)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
