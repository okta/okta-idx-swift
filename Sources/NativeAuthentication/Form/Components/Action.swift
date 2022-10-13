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

public protocol Action: SignInComponent {
    var id: String { get }
    var action: () -> Void { get }
}

public struct AnyAction: Identifiable {
    public let id: String
    public let action: any Action

    public init(_ action: any Action) {
        self.action = action
        self.id = action.id
    }
}

public struct ContinueAction: Action {
    public enum Intent {
        case signIn
        case signUp
        case restart
    }
    
    public let id: String
    public let intent: Intent
    public let label: String
    public let action: () -> Void
    
    public init(id: String, intent: Intent, label: String, action: @escaping () -> Void) {
        self.id = id
        self.intent = intent
        self.label = label
        self.action = action
    }
}

public struct SocialLoginAction: Action {
    public enum Provider {
        case apple
    }
    
    public let id: String
    public let provider: Provider
    public let action: () -> Void
    
    public init(id: String, provider: Provider, action: @escaping () -> Void) {
        self.id = id
        self.provider = provider
        self.action = action
    }
}

public struct RecoverAction: Action {
    public let id: String
    public let action: () -> Void
    
    public init(id: String, action: @escaping () -> Void) {
        self.id = id
        self.action = action
    }
}
