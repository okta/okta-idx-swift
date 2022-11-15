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
    var id: String? { get set }
    var components: [any SignInComponent] { get set }
}

public protocol Actionable {
    var action: ((_ component: any SignInComponent) -> Void)? { get set }
}

public protocol Authenticator {
    var name: String { get set }
    var displayName: String? { get set }
    var profile: String? { get set }
}

public struct EmailAuthenticator: Authenticator {
    public var name: String
    public var displayName: String?
    public var profile: String?
    
    public var send: (() -> Void)?
    public var resend: (() -> Void)?
    public var startPolling: (() -> Void)?
    public var stopPolling: (() -> Void)?

    public init(name: String) {
        self.name = name
    }
}

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct HeaderSection: SignInSection, Identifiable {
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct GenericSection: SignInSection, Identifiable {
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct MakeSelection: SignInSection, Actionable, Identifiable {
    public enum Selection {
        case enrollProfile, identify
    }
    
    public var id: String?
    public var selection: Selection
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, selection: Selection, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.selection = selection
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct IdentifyUser: SignInSection, Identifiable {
    public var id: String?
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RegisterUser: SignInSection, Actionable, Identifiable {
    public var id: String?
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SelectAuthenticator: SignInSection, Actionable, Identifiable {
    public enum Intent {
        case authenticate, enroll, recover
    }
    
    public var intent: Intent
    public var id: String?
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, intent: Intent, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.intent = intent
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ChallengeAuthenticator: SignInSection, Actionable, Identifiable {
    public var id: String?
    public var authenticator: any Authenticator
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, authenticator: any Authenticator, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.authenticator = authenticator
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RedirectIDP: SignInSection, Identifiable {
    public enum Provider {
        case okta, apple, google, facebook, linkedin, microsoft, other(_ name: String)
    }

    public var id: String?
    public let providers: [Provider]
    public var components: [any SignInComponent]
    
    public init(id: String? = nil, providers: [Provider], @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.providers = providers
        self.components = components()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RestartSignIn: SignInSection, Actionable, Identifiable {
    public var id: String?
    public var components: [any SignInComponent]
    public var action: ((_ component: any SignInComponent) -> Void)?

    public init(id: String? = nil, @ArrayBuilder<any SignInComponent> components: () -> [any SignInComponent]) {
        self.id = id
        self.components = components()
    }
}
