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
extension StringInputField: ComponentView {
    func body(in form: SignInForm, section: some SignInSection) -> AnyView {
        let keyboardType: UIKeyboardType
        let capitalization: Compatibility.TextInputAutocapitalizationMode?
        let autocorrectionDisabled: Bool
        let contentType: UITextContentType?
        
        switch inputStyle {
        case .email:
            keyboardType = .emailAddress
            contentType = .username
            capitalization = .never
            autocorrectionDisabled = true
        case .password:
            keyboardType = .default
            contentType = .password
            capitalization = .never
            autocorrectionDisabled = true
        case .generic:
            keyboardType = .default
            contentType = nil
            capitalization = nil
            autocorrectionDisabled = false
        case .name:
            keyboardType = .asciiCapable
            contentType = .name
            capitalization = .words
            autocorrectionDisabled = false
        }
        
        let result: any View
        result = VStack(spacing: 12.0) {
            HStack {
                if isSecure && id.hasSuffix("passcode") {
                    Image(systemName: "lock")
                } else if id.hasSuffix("identifier") {
                    Image(systemName: "at")
                }
                
                if isSecure {
                    SecureField(label, text: $value.value) {
                        section.action?(self)
                    }
                    .keyboardType(keyboardType)
                    .textContentType(contentType)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .compatibility.textInputAutocapitalization(capitalization)

                    if let inputSection = section as? InputSection,
                       let recoverAction = inputSection.components.first(type: RecoverAction.self)
                    {
                        recoverAction.body(in: form, section: inputSection)
                    }
                } else {
                    TextField(label, text: $value.value) {
                        section.action?(self)
                    }
                    .keyboardType(keyboardType)
                    .textContentType(contentType)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .compatibility.textInputAutocapitalization(capitalization)
                }
            }
            Divider()
        }

        return AnyView(result)
    }
}
