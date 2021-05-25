//
// Copyright (c) 2021, Okta, Inc. and/or its affiliates. All rights reserved.
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

protocol TestingCredentials {
    
    var username: String { get }
    var password: String { get }
    var clientId: String { get }
    var issuer: String { get }
    var scopes: String { get }
    var redirectUri: String { get }
    var a18nAPIKey: String { get }
    var a18nProfileId: String { get }
    var issuerUrl: String { get }
}

struct PasswordCredentials: TestingCredentials {
    
    enum Scenario {
        case regural
        case notAssigned
        case suspended
        case locked
        case deactivated
        
        var prefix: String {
            switch self {
            case .regural: return "PASSCODE"
            case .notAssigned: return "PASSCODE_NOT_ASSIGNED"
            case .suspended: return "PASSCODE_SUSPENDED"
            case .locked: return "PASSCODE_LOCKED"
            case .deactivated: return "PASSCODE_DEACTIVATED"
            }
        }
        
        var usernameKey: String {
            return "\(prefix)_USERNAME"
        }

        var passwordKey: String {
            return "\(prefix)_PASSWORD"
        }
    }
    
    let username: String
    let password: String
    let clientId: String
    let issuer: String
    let scopes: String
    let redirectUri: String
    let a18nAPIKey: String
    let a18nProfileId: String
    
    var issuerUrl: String {
        return "https://\(issuer)/oauth2/default"
    }
    
    init?(scenario: Scenario) {
        let env = ProcessInfo.processInfo.environment
        
        guard let clientId = env["CLIENT_ID"],
              let issuer = env["ISSUER_DOMAIN"],
              let scopes = env["SCOPES"],
              let redirectUri = env["REDIRECT_URI"],
              let a18nAPIKey = env["A18N_API_KEY"],
              let a18nProfileId = env["A18N_PROFILE_ID"],
              let username = env[scenario.usernameKey],
              let password = env[scenario.passwordKey] else
        {
            return nil
        }
        
        guard !clientId.isEmpty,
              !issuer.isEmpty,
              !scopes.isEmpty,
              !redirectUri.isEmpty,
              !a18nAPIKey.isEmpty,
              !a18nProfileId.isEmpty,
              !username.isEmpty,
              !password.isEmpty else
        {
            return nil
        }
        
        self.clientId = clientId
        self.issuer = issuer
        self.scopes = scopes
        self.redirectUri = redirectUri
        self.a18nAPIKey = a18nAPIKey
        self.a18nProfileId = a18nProfileId
        self.username = username
        self.password = password
    }
}
