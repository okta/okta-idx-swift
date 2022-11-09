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

public protocol SignInSection: Identifiable {
    static var type: SectionType { get }
    
    var id: String? { get set }
    var components: [any SignInComponent] { get set }
}

public protocol Actionable {
    var action: ((_ component: any SignInComponent) -> Void)? { get set }
}

public enum SectionType {
    case header, divider, body, footer
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct HeaderSection: SignInSection, Identifiable {
    public static let type = SectionType.header
    
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct BodySection: SignInSection, Identifiable {
    public static let type = SectionType.body
    
    public enum Option {
        case identifyUser, registerUser
    }
    
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct IdentifyUserSection: SignInSection, Identifiable {
    public static let type = SectionType.body
    
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RegisterUserSection: SignInSection, Actionable, Identifiable {
    public static let type = SectionType.body
    
    public var id: String?
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}
