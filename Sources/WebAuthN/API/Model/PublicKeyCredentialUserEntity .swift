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
 The PublicKeyCredentialUserEntity dictionary is used to supply additional user account attributes when creating a new credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-user-credential-params)
 */
public struct PublicKeyCredentialUserEntity: Codable {
    public let displayName: String
    public let id: [UInt8]
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case id
        case name
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        displayName = try values.decode(String.self, forKey: .displayName)
        id = Array(try values.decode(String.self, forKey: .id).utf8)
        name = try values.decode(String.self, forKey: .name)
    }
}
