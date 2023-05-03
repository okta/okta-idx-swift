//
//  AssertionObject.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/12/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Assertion bject returned from the authenticator to the user agent
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#authenticatorGetAssertion-return-values)
 */
struct AssertionObject {
    let credentialID: [UInt8]
    let userHandle: [UInt8]?
    let authenticatorData: AuthenticatorData
    let signature: Data
}
