//
//  PublicKeyCredentialCreationOptions.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Options for Credential Creation
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-makecredentialoptions)
 */
struct PublicKeyCredentialCreationOptions: Codable {
    var rp: PublicKeyCredentialRpEntity
    let user: PublicKeyCredentialUserEntity
    let challenge: [UInt8]
    let pubKeyCredParams: [PublicKeyCredentialParameters]
    let timeout: UInt64?
    let excludeCredentials: [PublicKeyCredentialDescriptor]
    let authenticatorSelection: AuthenticatorSelectionCriteria
    let attestation: AttestationConveyancePreference
    let extensions: AuthenticationExtensionsClientInputs?
    
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
    
    init(from decoder: Decoder) throws {
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
