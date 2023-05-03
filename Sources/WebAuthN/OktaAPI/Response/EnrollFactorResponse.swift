//
//  EnrollFactorResponse.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/11/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

/**
 Response returned when starting a factor enrollment
 
 - Note: [Okta Developer](https://developer.okta.com/docs/reference/api/factors/#enroll-webauthn-factor)
 */
struct EnrollFactorResponse: Codable {
    let created: Date
    let embedded: EnrollResponseEmbedded
    let factorType: String
    let id: String
    let lastUpdated: Date
    let links: EnrollResponseLinks
    let provider: String
    let status: String
    let vendorName: String
    
    enum CodingKeys: String, CodingKey {
        case created
        case embedded = "_embedded"
        case factorType
        case id
        case lastUpdated
        case links = "_links"
        case provider
        case status
        case vendorName
    }
}
