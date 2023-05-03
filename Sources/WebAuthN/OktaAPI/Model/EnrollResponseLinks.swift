//
//  EnrollResponseLinks.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/10/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct EnrollResponseLinks: Codable {
    let activateLink: ResponseLink
    let selfLink: ResponseLink
    let userLink: ResponseLink
    
    enum CodingKeys: String, CodingKey {
        case activateLink = "activate"
        case selfLink = "self"
        case userLink = "user"
    }
}
