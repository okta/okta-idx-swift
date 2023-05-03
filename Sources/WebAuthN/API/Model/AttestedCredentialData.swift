//
//  AttestedCredentialData.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Attested credential data is a variable-length byte array added to the authenticator data when generating an attestation object for a given credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-attested-credential-data)
 */
struct AttestedCredentialData {
    /// The AAGUID of the authenticator.
    let aaguid: [UInt8]
    /// Byte length L of Credential ID, 16-bit unsigned big-endian integer.
    let credentialIdLength: UInt16
    /// Credential ID
    let credentialId: [UInt8]
    /// The credential public key encoded in COSE_Key format
    let credentialPublicKey: COSEKey

    public func toBytes() -> [UInt8] {
        if self.aaguid.count != 16 {
           fatalError("<AttestedCredentialData> invalid aaguid length")
        }
        var result = aaguid
        result.append(UInt8((credentialIdLength & 0xff00) >> 8))
        result.append(UInt8((credentialIdLength & 0x00ff)))
        result.append(contentsOf: credentialId)
        result.append(contentsOf: credentialPublicKey.toBytes())
        return result
    }
}
