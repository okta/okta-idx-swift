//
//  CollectedClientDataType.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 This member contains the string "webauthn.create" when creating new credentials, and "webauthn.get" when getting an assertion from an existing credential. The purpose of this member is to prevent certain types of signature confusion attacks (where an attacker substitutes one legitimate signature for another).
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#dom-collectedclientdata-type)
 */
enum CollectedClientDataType: String, Codable {
    case create = "webauthn.create"
    case get = "webauthn.get"
}
