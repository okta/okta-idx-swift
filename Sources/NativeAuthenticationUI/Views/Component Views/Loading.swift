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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Loading: ComponentView {
    @ViewBuilder
    public func body(in form: SignInForm, section: any SignInSection) -> some View  {
        if #available(iOS 14.0, *) {
            if let text = text {
                ProgressView {
                    Text(text)
                }
            } else {
                ProgressView()
            }
        } else {
            Text("Loading...")
        }
    }
}

#if DEBUG
struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        let section = GenericSection {[]}
        let form = SignInForm(intent: .custom) {
            section
        }
        
        VStack(spacing: 20) {
            Loading(id: "text", text: "Loading ...")
                .body(in: form, section: section)
            Loading(id: "plain")
                .body(in: form, section: section)
        }
        .padding(20)
    }
}
#endif
