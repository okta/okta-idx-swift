//
//  TokenBinding.swift
//  Okta Verify
//
//  Created by Michael Biviano on 10/6/22.
//  Copyright © 2022 Okta. All rights reserved.
//

import Foundation

struct TokenBinding: Codable {
    let status: TokenBindingStatus
    let id: String
}
