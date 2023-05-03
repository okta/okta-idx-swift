//
//  AuthenticatorAttachment.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 This enumeration’s values describe authenticators' attachment modalities. Relying Parties use this to express a preferred authenticator attachment modality when calling navigator.credentials.create() to create a credential.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#enum-attachment)
 */
enum AuthenticatorAttachment: String, Codable {
    case platform
    case crossPlatform = "cross-platform"
}
