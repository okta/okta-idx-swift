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
extension SelectAuthenticator: SectionView {
    @ViewBuilder
    func body(in form: SignInForm, @ViewBuilder renderer: ([any SignInComponent]) -> some View) -> any View {
        let currentAuthenticator = form.sections.compactMap({ $0 as? any HasAuthenticator }).first

        VStack(spacing: 12.0) {
            if let currentAuthenticator = currentAuthenticator {
                HStack {
                    VStack {
                        Divider()
                    }
                    Text("Or select another security method")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    VStack {
                        Divider()
                    }
                }
                .padding(.bottom, 12.0)
                .padding(.top, 24.0)
            } else {
                Text("Verify it's you with a security method")
                    .fontWeight(.bold)
                Text("Select from the following options")
            }
            
            renderer(components)
        }.padding(.bottom, 12.0)
    }
}
