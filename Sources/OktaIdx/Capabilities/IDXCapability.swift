//
// Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

public protocol AuthenticatorCapability {
}

public protocol RemediationCapability {
}

public struct Capability {
}

public protocol CapabilityCollection: AnyObject {
    associatedtype CapabilityType
    var capabilities: [CapabilityType] { get }
    func capability<T>(_ type: T.Type) -> T?
}

public extension CapabilityCollection {
    func capability<T>(_ type: T.Type) -> T? {
        capabilities.first { $0 is T } as? T
    }
}

extension IDXClient.Authenticator: CapabilityCollection {
    public typealias CapabilityType = AuthenticatorCapability
    
    public var sendable: Capability.Sendable? { capability(Capability.Sendable.self) }
    public var resendable: Capability.Resendable? { capability(Capability.Resendable.self) }
    public var recoverable: Capability.Recoverable? { capability(Capability.Recoverable.self) }
    public var passwordSettings: Capability.PasswordSettings? { capability(Capability.PasswordSettings.self) }
    public var pollable: Capability.Pollable? { capability(Capability.Pollable.self) }
    public var profile: Capability.Profile? { capability(Capability.Profile.self) }
}

extension IDXClient.Remediation: CapabilityCollection {
    public typealias CapabilityType = RemediationCapability
    
    public var pollable: Capability.Pollable? { capability(Capability.Pollable.self) }
    public var socialIdp: Capability.SocialIDP? { capability(Capability.SocialIDP.self) }
}
