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

struct Compatibility<Content> {
    let content: Content
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    var compatibility: Compatibility<Self> { Compatibility(content: self) }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Compatibility where Content: View {
    enum KeyboardDismissMode {
        case automatic, immediately, interactively, never
    }
    
    func withKeyboardBehavior(mode: KeyboardDismissMode) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            let dismissMode: ScrollDismissesKeyboardMode
            switch mode {
            case .automatic:
                dismissMode = .automatic
            case .immediately:
                dismissMode = .immediately
            case .interactively:
                dismissMode = .interactively
            case .never:
                dismissMode = .never
            }
            return content.scrollDismissesKeyboard(dismissMode)
        } else {
            return content
        }
    }
}
