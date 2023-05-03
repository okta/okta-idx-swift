//
//  PublicKeyCredentialParameters.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Parameters for Credential Generation
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dictionary-credential-params)
 */
struct PublicKeyCredentialParameters: Codable {
    let alg: COSEAlgorithmIdentifier
    let type: PublicKeyCredentialType
}
