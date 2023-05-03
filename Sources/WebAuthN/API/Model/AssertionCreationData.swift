//
//  AssertionCreationData.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/12/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 The result of invoking get on the client
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#sctn-getAssertion)
 */
struct AssertionCreationData {
    let credentialIDResult: [UInt8]
    let clientDataJSONResult: Data
    let authenticatorDataResult: Data
    let signatureResult: Data
    let userHandleResult: [UInt8]?
    let clientExtensionResults: AuthenticationExtensionsClientOutputs
}
