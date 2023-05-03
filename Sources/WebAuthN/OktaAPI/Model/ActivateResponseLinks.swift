//
//  ActivateResponseLinks.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/10/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct ActivateResponseLinks: Codable {
    let selfLink: ResponseLink
    let userLink: ResponseLink
    let verifyLink: ResponseLink
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case userLink = "user"
        case verifyLink = "verify"
    }
}
