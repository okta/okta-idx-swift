//
//  ChallengeFactorResponse.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/11/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct ChallengeFactorResponse: Codable {
    let embedded: ChallengeResponseEmbedded
    let factorResult: String
    let links: ChallengeResponseLinks
    let profile: ChallengeResponseProfile
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case factorResult
        case links = "_links"
        case profile
    }
}
