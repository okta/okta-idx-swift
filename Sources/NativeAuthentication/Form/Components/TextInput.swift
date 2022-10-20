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

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol InputField: SignInComponent, Identifiable {
    var id: String { get }
    var label: String { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct StringInputField: InputField {
    public var id: String
    public var label: String
    public var isSecure: Bool
    public var inputStyle: InputStyle
    public var contentType: ContentType
    
    @ObservedObject public var value: SignInValue<String>
    
    public enum InputStyle {
        case email, name, password, generic
    }
    
    public enum ContentType {
        case name, firstName, middleName, lastName, telephoneNumber, emailAddress, username, password, newPassword, oneTimeCode, generic
    }
    
    public init(id: String, label: String, isSecure: Bool, inputStyle: InputStyle = .generic, contentType: ContentType = .generic, value: SignInValue<String>) {
        self.id = id
        self.label = label
        self.isSecure = isSecure
        self.inputStyle = inputStyle
        self.contentType = contentType
        self.value = value
    }
}
