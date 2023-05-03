//
//  AttestationObject.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Authenticators SHOULD also provide some form of attestation, if possible. If an authenticator does, the basic requirement is that the authenticator can produce, for each credential public key, an attestation statement verifiable by the WebAuthn Relying Party. Typically, this attestation statement contains a signature by an attestation private key over the attested credential public key and a challenge, as well as a certificate or similar data providing provenance information for the attestation public key, enabling the Relying Party to make a trust decision.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-attestation)
 */
struct AttestationObject {
    let fmt: String
    let authData: AuthenticatorData
    let attStmt: SimpleOrderedDictionary<String>
    
    func toBytes() -> [UInt8]? {
        let dict = SimpleOrderedDictionary<String>()
        dict.addBytes("authData", authData.toBytes())
        dict.addString("fmt", fmt)
        dict.addStringKeyMap("attStmt", attStmt)

        return CBORWriter()
            .putStringKeyMap(dict)
            .getResult()
    }
}
