//
//  PublicKeyCredentialUserEntity .swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The PublicKeyCredentialUserEntity dictionary is used to supply additional user account attributes when creating a new credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-user-credential-params)
 */
struct PublicKeyCredentialUserEntity: Codable {
    let displayName: String
    let id: [UInt8]
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        displayName = try values.decode(String.self, forKey: .displayName)
        id = Array(try values.decode(String.self, forKey: .id).utf8)
        name = try values.decode(String.self, forKey: .name)
    }
}
