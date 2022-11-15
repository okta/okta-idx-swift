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
import Combine
import DynamicAuthentication
import NativeAuthenticationUI

struct AppView: View {
    final class ViewModel: ObservableObject {
        @Published var credential: Credential?
        @Published var nativeAuth: NativeAuthentication
        
        private var nativeAuthTokenCancellable: AnyCancellable?
        private var defaultCredentialCancellable: (any NSObjectProtocol)?

        init(nativeAuth: NativeAuthentication = NativeAuthentication(provider: try! DynamicAuthenticationProvider())) {
            self.credential = Credential.default
            self.nativeAuth = nativeAuth
            self.defaultCredentialCancellable = nil
            
            self.nativeAuthTokenCancellable = nativeAuth.$token.sink { token in
                guard let token = token else { return }
                self.credential = try? Credential.store(token)
            }

            self.defaultCredentialCancellable = NotificationCenter.default.addObserver(forName: .defaultCredentialChanged,
                                                                                  object: nil,
                                                                                  queue: .main) { notification in
                if notification.object == nil {
                    self.nativeAuth.reset()
                    self.credential = nil
                }
            }
        }
    }

    @StateObject var viewModel = ViewModel()

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if let credential = viewModel.credential {
            MainView(credential: credential)
        } else {
            viewModel.nativeAuth.rendererView() { token in
                print("Woohoo")
            }
            .frame(maxWidth: .infinity)
        }
    }
}
