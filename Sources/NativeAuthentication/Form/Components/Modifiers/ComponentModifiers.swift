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

import Foundation

//extension StringInputField {
//    public func label(_ label: String) -> StringInputField {
//        var result = self
//        result.label = label
//        return result
//    }
//    
//    public func isSecret(_ isSecret: Bool) -> StringInputField {
//        var result = self
//        result.isSecret = isSecret
//        return result
//    }
//    
//    public func value(_ value: String) -> StringInputField {
//        var result = self
//        result.value = value
//        return result
//    }
//}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
extension StringInputField {
    public func length(_ dimension: Length, amount: Int?) -> Self {
        var result = self
        switch dimension {
        case .minimum: result.minimumLength = amount
        case .maximum: result.maximumLength = amount
        }
        return result
    }
}

extension FormLabel {
    public func style(_ style: FormLabel.Style) -> Self {
        var result = self
        result.style = style
        return result
    }

    public func text(_ text: String) -> Self {
        var result = self
        result.text = text
        return result
    }
}

extension AuthenticatorOption {
    public func authenticator(_ authenticator: any Authenticator) -> Self {
        var result = self
        result.authenticator = authenticator
        return result
    }

    public func name(_ name: String?) -> Self {
        var result = self
        result.name = name
        return result
    }

    public func label(_ label: String?) -> Self {
        var result = self
        result.label = label
        return result
    }

    public func isCurrentOption(_ option: Bool) -> Self {
        var result = self
        result.isCurrentOption = option
        return result
    }
}

extension ChoiceOption {
    public func isSelected(_ option: Bool) -> Self {
        var result = self
        result.isSelected = option
        return result
    }
}

extension Authenticator {
    public func profile(_ profile: String?) -> Self {
        var result = self
        result.profile = profile
        return result
    }
    
    public func displayName(_ displayName: String?) -> Self {
        var result = self
        result.displayName = displayName
        return result
    }
}

//extension Action {
//    public func text(_ text: String) -> Action {
//        var result = self
//        result.text = text
//        return result
//    }
//
//    public func style(_ style: Action.Style) -> Action {
//        var result = self
//        result.style = style
//        return result
//    }
//}
//
//extension Option {
//    public func text(_ text: String) -> Option {
//        var result = self
//        result.text = text
//        return result
//    }
//}
