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
    @State var username: String = ""
    @State var password: String = ""
    @State var rememberMe: Bool = false
    
    let auth: NativeAuthentication
    
    var body: some View {
        auth.rendererView()
            .onAppear {
                Task {
                    do {
                        try await auth.client.start()
                    } catch {
                        print(error)
                    }
                }
            }
            .frame(maxWidth: .infinity)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//        .previewInterfaceOrientation(.landscapeRight)
//    }
//}
