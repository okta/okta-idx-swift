//
//  PublicKeyCredentialSource.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/7/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 A credential source used by an authenticator to generate authentication assertions.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#public-key-credential-source)
 */
struct PublicKeyCredentialSource {
    /// Credential type
    let type: PublicKeyCredentialType
    /// A Credential ID.
    let credentialID: [UInt8]
    /// The credential private key.
    let privateKey: Data
    /// The Relying Party Identifier, for the Relying Party this public key credential source is scoped to.
    let rpID: String
    /// The user handle associated when this public key credential source was created. This item is nullable.
    let userHandle: [UInt8]
    /// OPTIONAL other information used by the authenticator to inform its UI. For example, this might include the user’s displayName. otherUI is a mutable item and SHOULD NOT be bound to the public key credential source in a way that prevents otherUI from being updated.
    let otherUI: String?
}
