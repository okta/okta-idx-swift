//
//  ActivateFactorResponse.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/11/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

class ActivateFactorResponse: Codable {
    let created: Date
    let factorType: String
    let id: String
    let lastUpdated: Date
    let links: ActivateResponseLinks
    let profile: ActivateResponseProfile
    let provider: String
    let status: String
    let vendorName: String
    
    enum CodingKeys: String, CodingKey {
        case created
        case factorType
        case id
        case lastUpdated
        case links = "_links"
        case profile
        case provider
        case status
        case vendorName
    }
}
