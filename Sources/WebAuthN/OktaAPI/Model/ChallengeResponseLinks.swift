//
//  ChallengeResponseLinks.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/11/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct ChallengeResponseLinks: Codable {
    let factorLink: ResponseLink
    let verifyLink: ResponseLink
    
    enum CodingKeys: String, CodingKey {
        case factorLink = "factor"
        case verifyLink = "verify"
    }
}
