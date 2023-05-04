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
 The PublicKeyCredentialRequestOptions dictionary supplies get() with the data it needs to generate an assertion. Its challenge member MUST be present, while its other members are OPTIONAL.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-assertion-options)
 */
public struct PublicKeyCredentialRequestOptions: Codable {
    public let allowCredentials: [PublicKeyCredentialDescriptor]?
    public let challenge: [UInt8]
    public let extensions: AuthenticationExtensionsClientInputs?
    public internal(set) var rpID: String?
    public let timeout: UInt64?
    public let userVerification: UserVerificationRequirement?
    
    enum CodingKeys: String, CodingKey {
        case allowCredentials
        case challenge
        case extensions
        case rpID
        case timeout
        case userVerification
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        allowCredentials = values.contains(.allowCredentials) ? try values.decode([PublicKeyCredentialDescriptor].self, forKey: .allowCredentials) : nil
        challenge = Array(try values.decode(String.self, forKey: .challenge).utf8)
        extensions = values.contains(.extensions) ? try values.decode(AuthenticationExtensionsClientInputs.self, forKey: .extensions) : nil
        rpID = values.contains(.rpID) ? try values.decode(String.self, forKey: .rpID) : nil
        timeout = values.contains(.timeout) ? try values.decode(UInt64.self, forKey: .timeout) : nil
        userVerification = values.contains(.userVerification) ? try values.decode(UserVerificationRequirement.self, forKey: .userVerification) : nil
    }
}
