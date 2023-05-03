//
//  AuthenticatorData.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The authenticator data structure encodes contextual bindings made by the authenticator.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-authenticator-data)
 */
struct AuthenticatorData {
    
    /// SHA-256 hash of the RP ID the credential is scoped to.
    let rpIdHash: [UInt8]
    /// Flags (bit 0 is the least significant bit):
    let flags: AuthenticatorDataFlags
    /// Signature counter, 32-bit unsigned big-endian integer.
    let signCount: UInt32
    /// Attested credential data (if present)
    let attestedCredentialData: AttestedCredentialData?
    /// Extension-defined authenticator data.
    let extensions: SimpleOrderedDictionary<String>
    
    public func toBytes() -> [UInt8] {
        if self.rpIdHash.count != 32 {
            fatalError("<AuthenticatorData> rpIdHash should be 32 bytes")
        }

        var result = rpIdHash
        result.append(flags.toByte())

        result.append(UInt8((signCount & 0xff000000) >> 24))
        result.append(UInt8((signCount & 0x00ff0000) >> 16))
        result.append(UInt8((signCount & 0x0000ff00) >>  8))
        result.append(UInt8((signCount & 0x000000ff)))

        if let attestedData = attestedCredentialData {
            result.append(contentsOf: attestedData.toBytes())
        }

        if !extensions.isEmpty {
            let builder = CBORWriter()
            _ = builder.putStringKeyMap(extensions)
            result.append(contentsOf: builder.getResult())
        }

        return result
    }
}
