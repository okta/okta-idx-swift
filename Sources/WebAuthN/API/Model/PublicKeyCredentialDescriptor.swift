//
//  PublicKeyCredentialDescriptor.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 This dictionary contains the attributes that are specified by a caller when referring to a public key credential as an input parameter to the create() or get() methods. It mirrors the fields of the PublicKeyCredential object returned by the latter methods.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-credential-descriptor)
 */
struct PublicKeyCredentialDescriptor: Codable {
    /// This member contains the credential ID of the public key credential the caller is referring to.
    let id: [UInt8]
    /// This member contains the type of the public key credential the caller is referring to.
    let type: PublicKeyCredentialType
    /// This OPTIONAL member contains a hint as to how the client might communicate with the managing authenticator of the public key credential the caller is referring to. The values SHOULD be members of AuthenticatorTransport but client platforms MUST ignore unknown values.
    let transports: [AuthenticatorTransport]
}
