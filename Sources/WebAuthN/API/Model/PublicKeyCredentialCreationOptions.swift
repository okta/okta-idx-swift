// Copyright (c) 2023-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

/**
 Options for Credential Creation
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-makecredentialoptions)
 */
public struct PublicKeyCredentialCreationOptions: Codable {
    public internal(set) var rp: PublicKeyCredentialRpEntity
    public let user: PublicKeyCredentialUserEntity
    public let challenge: [UInt8]
    public let pubKeyCredParams: [PublicKeyCredentialParameters]
    public let timeout: UInt64?
    public let excludeCredentials: [PublicKeyCredentialDescriptor]
    public let authenticatorSelection: AuthenticatorSelectionCriteria
    public let attestation: AttestationConveyancePreference
    public let extensions: AuthenticationExtensionsClientInputs?
    
    enum CodingKeys: String, CodingKey {
        case rp
        case user
        case challenge
        case pubKeyCredParams
        case timeout
        case excludeCredentials
        case authenticatorSelection
        case attestation
        case extensions
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        rp = try values.decode(PublicKeyCredentialRpEntity.self, forKey: .rp)
        user = try values.decode(PublicKeyCredentialUserEntity.self, forKey: .user)
        challenge = Array(try values.decode(String.self, forKey: .challenge).utf8)
        pubKeyCredParams = try values.decode([PublicKeyCredentialParameters].self, forKey: .pubKeyCredParams)
        timeout = values.contains(.timeout) ? try values.decode(UInt64.self, forKey: .timeout) : nil
        excludeCredentials = try values.decode([PublicKeyCredentialDescriptor].self, forKey: .excludeCredentials)
        authenticatorSelection = try values.decode(AuthenticatorSelectionCriteria.self, forKey: .authenticatorSelection)
        attestation = try values.decode(AttestationConveyancePreference.self, forKey: .attestation)
        extensions = values.contains(.extensions) ? try values.decode(AuthenticationExtensionsClientInputs.self, forKey: .extensions) : nil
    }
}
