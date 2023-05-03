//
//  PublicKeyCredentialRpEntity .swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The PublicKeyCredentialRpEntity dictionary is used to supply additional Relying Party attributes when creating a new credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-rp-credential-params)
 */
struct PublicKeyCredentialRpEntity: Codable {
    var id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        id = values.contains(.id) ? try values.decode(String.self, forKey: .id) : name
    }
}
