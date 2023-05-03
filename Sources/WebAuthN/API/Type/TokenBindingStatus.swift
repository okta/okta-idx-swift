//
//  TokenBindingStatus.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 This member contains the type of the public key credential the caller is referring to.
 
 - Note: [W3C Reccomendation](https://www.w3.org/TR/webauthn/#enumdef-tokenbindingstatus)
 */
enum TokenBindingStatus: String, Codable {
    case present
    case supported
}
