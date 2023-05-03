//
//  UserVerificationRequirement.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 A WebAuthn Relying Party may require user verification for some of its operations but not for others, and may use this type to express its needs.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#enum-userVerificationRequirement)
 */
enum UserVerificationRequirement: String, Codable {
    case required
    case preferred
    case discouraged
}
