//
//  PublicKeyCredentialRequestOptions.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/12/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The PublicKeyCredentialRequestOptions dictionary supplies get() with the data it needs to generate an assertion. Its challenge member MUST be present, while its other members are OPTIONAL.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-assertion-options)
 */
struct PublicKeyCredentialRequestOptions: Codable {
    let allowCredentials: [PublicKeyCredentialDescriptor]?
    let challenge: [UInt8]
    let extensions: AuthenticationExtensionsClientInputs?
    var rpID: String?
    let timeout: UInt64?
    let userVerification: UserVerificationRequirement?
    
    enum CodingKeys: String, CodingKey {
        case allowCredentials
        case challenge
        case extensions
        case rpID
        case timeout
        case userVerification
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        allowCredentials = values.contains(.allowCredentials) ? try values.decode([PublicKeyCredentialDescriptor].self, forKey: .allowCredentials) : nil
        challenge = Array(try values.decode(String.self, forKey: .challenge).utf8)
        extensions = values.contains(.extensions) ? try values.decode(AuthenticationExtensionsClientInputs.self, forKey: .extensions) : nil
        rpID = values.contains(.rpID) ? try values.decode(String.self, forKey: .rpID) : nil
        timeout = values.contains(.timeout) ? try values.decode(UInt64.self, forKey: .timeout) : nil
        userVerification = values.contains(.userVerification) ? try values.decode(UserVerificationRequirement.self, forKey: .userVerification) : nil
    }
}
