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
extension FormLabel: ComponentView {
    @ViewBuilder
    public func body(in form: SignInForm, section: any SignInSection) -> some View  {
        switch style {
        case .heading:
            Text(text)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.bottom)
        case .caption:
            Text(text)
                .font(.callout)
        case .description:
            Text(text)
                .font(.body)
        case .error:
            Text(text)
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}

#if DEBUG
@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
struct FormLabel_Previews: PreviewProvider {
    static var previews: some View {
        let section = GenericSection {[]}
        let form = SignInForm(intent: .custom) {
            section
        }
        
        FormLabel(id: "heading", text: "Sign in", style: .heading)
            .body(in: form, section: section)
        FormLabel(id: "caption", text: "This is a caption", style: .caption)
            .body(in: form, section: section)
        FormLabel(id: "description", text: "This is a description", style: .description)
            .body(in: form, section: section)
        FormLabel(id: "error", text: "This is an error", style: .error)
            .body(in: form, section: section)
    }
}
#endif
