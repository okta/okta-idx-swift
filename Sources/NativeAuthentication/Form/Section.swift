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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SignInSection: Identifiable {
    public enum SectionType {
        case header, body, footer
    }

    public var type: SectionType
    public var id: String
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(_ type: SectionType, id: String, @ComponentBuilder components: () -> [any SignInComponent], action: ((any SignInComponent) -> Void)? = nil) {
        self.init(type, id: id, components: components(), action: action)
    }

    public init(_ type: SectionType, id: String, components: [any SignInComponent], action: ((any SignInComponent) -> Void)? = nil) {
        self.type = type
        self.id = id
        self.components = components
        self.action = action
    }
}
